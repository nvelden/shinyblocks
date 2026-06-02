# Built-in visual style profiles.
#
# A style profile is a curated pack of visual-feel tokens (control sizing,
# spacing, shadows, focus/disabled treatment, motion) emitted as `--sb-*`
# custom properties. This is separate from `block_theme()`, which owns
# semantic *colour* tokens. See ADR 0021.
#
# The `default` profile's values live in the runtime stylesheet
# (`frontend/src/styles/runtime.css`) as the `--sb-*` defaults, so its built-in
# override list here is empty: selecting `default` changes nothing unless the
# caller supplies explicit overrides.
#
# Each non-default profile lists only the curated shared `--sb-*` tokens that
# differ from the default. block_page() emits those as a scoped <style> and also
# stamps `data-sb-style="<profile>"` on `.sb-app`, which activates the
# profile-scoped component CSS in the stylesheets for differences that cannot be
# expressed by a shared token (radii, pill geometry, slider/switch metrics).
#
# `luma` mirrors official upstream Radix Luma
# (apps/v4/registry/styles/style-luma.css). The shared tokens below capture
# Luma's tighter control padding/gap, flat (shadow-less) controls, heavier card
# elevation (shadow-md), wider dialog gap, lighter overlay shadow (shadow-lg),
# and softer 30% focus ring. Luma's larger radii and component-specific shapes
# live in the `[data-sb-style="luma"]` CSS. See
# docs/research/2026-06-01-upstream-luma-comparison.md.
style_profiles <- list(
  default = list(),
  luma = list(
    control_padding_x = "0.75rem",
    control_gap = "0.375rem",
    control_shadow = "none",
    surface_shadow = "0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)",
    overlay_gap = "1.5rem",
    overlay_shadow = "0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)",
    focus_ring_opacity = "30%"
  )
)

style_profile_names <- function() {
  names(style_profiles)
}

# Fixed public allowlist mapping ergonomic snake_case R names to the curated
# `--sb-*` custom properties. Raw CSS-variable names are deliberately not a
# public API, so internal CSS stays free to evolve.
style_token_map <- function() {
  c(
    font_body = "sb-font-body",
    font_heading = "sb-font-heading",
    font_mono = "sb-font-mono",
    control_font_size = "sb-control-font-size",
    control_font_weight = "sb-control-font-weight",
    control_height = "sb-control-height",
    control_height_sm = "sb-control-height-sm",
    control_height_lg = "sb-control-height-lg",
    control_padding_x = "sb-control-padding-x",
    control_gap = "sb-control-gap",
    surface_padding = "sb-surface-padding",
    surface_gap = "sb-surface-gap",
    overlay_padding = "sb-overlay-padding",
    overlay_gap = "sb-overlay-gap",
    control_shadow = "sb-control-shadow",
    surface_shadow = "sb-surface-shadow",
    overlay_shadow = "sb-overlay-shadow",
    focus_ring_width = "sb-focus-ring-width",
    focus_ring_opacity = "sb-focus-ring-opacity",
    disabled_opacity = "sb-disabled-opacity",
    transition_duration = "sb-transition-duration"
  )
}

style_override_names <- function() {
  names(style_token_map())
}

validate_style_profile <- function(profile) {
  if (!is.character(profile) || length(profile) != 1 || !nzchar(profile)) {
    stop("`profile` must be a single supported style-profile name.", call. = FALSE)
  }
  if (!profile %in% style_profile_names()) {
    stop(
      sprintf(
        "Unknown style profile `%s`. Supported profiles: %s.",
        profile,
        paste(sprintf("`%s`", style_profile_names()), collapse = ", ")
      ),
      call. = FALSE
    )
  }
  profile
}

style_profile <- function(profile) {
  style_profiles[[validate_style_profile(profile)]]
}
