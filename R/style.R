#' Select a visual style profile
#'
#' Selects a built-in visual style profile and, optionally, layers explicit
#' overrides on top of it. A *style profile* controls visual feel — control
#' sizing, spacing, surface and overlay metrics, elevation, focus and disabled
#' treatment, and motion — through a curated set of `--sb-*` custom properties.
#' This is separate from [block_theme()], which owns semantic light/dark
#' **colour** tokens. Portaled overlays stay inside their originating runtime
#' root and therefore retain scoped profile overrides.
#'
#' Pass the result to [block_page()] via its `style` argument. The profile is
#' applied page-wide: `block_page()` places `data-sb-style="<profile>"` on the
#' `.sb-app` shell, so profile tokens also reach dialog, popover, tooltip, and
#' select portal content (the portal root lives inside `.sb-app`).
#'
#' Overrides use ergonomic snake-case names from a fixed allowlist (for example
#' `control_height`, `surface_padding`, `focus_ring_width`); see
#' [block_style_profiles()] for available profiles. Raw `--sb-*` CSS-variable
#' names are intentionally not accepted.
#'
#' @param profile Built-in style profile name. Defaults to `"default"`, which
#'   preserves the current shinyblocks visuals.
#' @param ... Named token overrides from the curated allowlist, such as
#'   `control_height = "2.5rem"`. Override values win over the profile's
#'   built-in values.
#' @param scope Optional CSS selector. When supplied, the profile's tokens
#'   (and any `...` overrides) apply only to elements matching `scope` (and the
#'   runtime/portal roots inside it) instead of the whole page. Defaults to
#'   `NULL` (page-wide).
#'
#'   Scope covers every token-driven part of a profile — radii, surfaces,
#'   borders, shadows, and the shared `--sb-*` tokens. A profile may also carry a
#'   little genuinely-structural CSS (for example a switch's enlarged geometry or
#'   a dialog's blurred scrim) that is keyed off a page-level
#'   `data-sb-style="<profile>"` attribute, which `scope` alone does not set. For
#'   full per-subtree fidelity, also place `data-sb-style="<profile>"` on the
#'   scope element (the showcase's scoped previews do this). Passing `style` to
#'   [block_page()] applies the profile page-wide and needs none of this.
#'
#' @return A `shinyblocks_style` object consumed by [block_page()].
#' @family theme
#' @export
#' @examples
#' block_style("default")
#' block_style("default", control_height = "2.5rem", surface_gap = "2rem")
block_style <- function(profile = "default", ..., scope = NULL) {
  profile <- validate_style_profile(profile)
  overrides <- list(...)
  names_overrides <- names(overrides)

  if (length(overrides) > 0 && (is.null(names_overrides) || any(!nzchar(names_overrides)))) {
    stop("`block_style()` overrides must be named.", call. = FALSE)
  }

  invalid <- setdiff(names_overrides, style_override_names())
  if (length(invalid) > 0) {
    stop(
      sprintf(
        "Unknown style override(s): %s. Supported overrides: %s.",
        paste(sprintf("`%s`", invalid), collapse = ", "),
        paste(sprintf("`%s`", style_override_names()), collapse = ", ")
      ),
      call. = FALSE
    )
  }

  if (!is.null(scope) && (!is.character(scope) || length(scope) != 1 || !nzchar(scope))) {
    stop("`scope` must be NULL or a single non-empty CSS selector.", call. = FALSE)
  }

  values <- utils::modifyList(style_profile(profile), overrides)

  style_tag <- NULL
  if (length(values) > 0) {
    token_map <- style_emit_token_map()
    decls <- paste(
      vapply(
        names(values),
        function(name) sprintf("--%s: %s;", token_map[[name]], values[[name]]),
        character(1)
      ),
      collapse = ""
    )

    roots <- if (is.null(scope)) {
      c(
        sprintf(".sb-app[data-sb-style=\"%s\"]", profile),
        sprintf("[data-shinyblocks-scope][data-sb-style=\"%s\"]", profile)
      )
    } else {
      scope
    }
    style_css <- paste(vapply(roots, function(root) {
      paste0(
        root, "{", decls, "}",
        root, " [data-shinyblocks-scope],",
        root, " [data-shinyblocks-root],",
        root, " [data-shinyblocks-portal-root]{", decls, "}"
      )
    }, character(1)), collapse = "")

    style_tag <- attach_shinyblocks_deps(
      htmltools::tags$style(
        class = "sb-style-overrides",
        htmltools::HTML(style_css)
      ),
      scope = FALSE
    )
  }

  structure(
    list(profile = profile, style = style_tag),
    class = "shinyblocks_style"
  )
}

#' Supported built-in style profiles
#'
#' @return A character vector of built-in style-profile names accepted by
#'   [block_style()].
#' @family theme
#' @export
#' @examples
#' block_style_profiles()
block_style_profiles <- function() {
  style_profile_names()
}
