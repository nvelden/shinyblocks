# ADR 0011: CRAN-Readiness CI

## Status

Accepted (2026-05-08)

## Context

The package should be CRAN-ready from the beginning, not retrofitted at the
end. Every phase should catch portability, dependency, documentation, and
package-check problems early.

The workflow actions used for package checks are versioned dependencies. They
must follow the project's version verification policy: verify the latest
authoritative upstream version before adding or changing workflow files.

Verified on 2026-05-08:

- `actions/checkout@v6` is the current major version for repository checkout.
- `r-lib/actions@v2` is the current major version for R actions, including
  `setup-r`, `setup-r-dependencies`, `setup-pandoc`, `setup-tinytex`, and
  `check-r-package`.

## Decision

Add CRAN-readiness CI in Phase 1C, before component work expands.

Create `.github/workflows/R-CMD-check.yaml` using the latest verified major
workflow actions:

```yaml
uses: actions/checkout@v6
uses: r-lib/actions/setup-pandoc@v2
uses: r-lib/actions/setup-r@v2
uses: r-lib/actions/setup-r-dependencies@v2
uses: r-lib/actions/check-r-package@v2
```

The routine workflow runs on push and pull request. It checks:

- Ubuntu with R devel;
- Ubuntu with R release;
- Ubuntu with R oldrel-1;
- macOS with R release;
- Windows with R release.

The workflow should set minimal token permissions:

```yaml
permissions:
  contents: read
```

Use `r-lib/actions/check-r-package@v2` for the routine package check. Routine
phase checks may skip PDF manual generation (`manual: false` or equivalent
`--no-manual`) so CI does not depend on TeX for every commit.

Add a separate strict release workflow,
`.github/workflows/cran-release-check.yaml`, triggered manually with
`workflow_dispatch`. It runs the full CRAN-style release gate:

- `R CMD check --as-cran`;
- PDF manual checks with TeX available via `r-lib/actions/setup-tinytex@v2`;
- URL checks;
- spell checks;
- pkgdown build;
- Shinylive export smoke once Phase 1C has implemented it.

The release workflow may also run on a weekly schedule against the default
branch so upstream dependency and runner changes are caught before a release.

## Version Verification Requirement

Before committing either workflow:

1. verify the latest `actions/checkout` major version from the upstream
   `actions/checkout` repository or GitHub Marketplace;
2. verify the latest `r-lib/actions` major version from the upstream
   `r-lib/actions` repository or documentation;
3. record the checked date and versions in this ADR or the phase-exit file;
4. update the workflow pins if upstream has moved to a newer current major.

Do not copy old examples that still use `actions/checkout@v4` or older
`r-lib/actions` pins unless a specific compatibility issue is documented.

## Consequences

- CRAN portability problems are visible from the first infrastructure phase.
- Workflow files become package-facing artifacts and should be committed to the
  public repository.
- The routine CI stays fast enough for normal development, while the strict
  release workflow covers full CRAN expectations.
- Workflow action versions are reviewed deliberately instead of inherited from
  stale examples.

## References

- `actions/checkout`: current checkout action major version verified as v6 on
  2026-05-08.
- `r-lib/actions`: current R action major version verified as v2 on
  2026-05-08.
