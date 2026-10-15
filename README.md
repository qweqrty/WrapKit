# WrapKit

## Project generation

Run `make project`. The command uses the first working Tuist installation found in `PATH`, including Homebrew and mise shims.

- Registry-capable Tuist versions resolve available packages through Tuist Registry and automatically fall back to Git for packages that are not present there.
- Older Tuist versions continue to work through Git resolution.
- If Tuist is missing, the command asks before downloading the pinned, checksum-verified distribution into the user cache. Declining cancels without changing generated sources.
- When dependency locks need regeneration, any different installed Tuist version keeps working normally; the pinned resolver is cached automatically only for that deterministic lock update.
- In a non-interactive shell, install Tuist yourself or run `make tuist-download` explicitly before `make project`.
- To bypass Registry manually, run `TUIST_USE_REGISTRY=0 make project`.

CI uses `make ci-project`, which downloads the same pinned distribution non-interactively and then runs the regular `make project` flow.

After changing dependencies in `Tuist/Package.swift`, run the usual `make project`. It detects the manifest change and automatically regenerates `Tuist/Package.resolved` for Git fallback, `Tuist/Package.registry.resolved` for Registry-first resolution, and their integrity state with the pinned CI Tuist version. Do not edit package kinds or lock state manually: SwiftPM uses Registry when the package is available and falls back to Git when it is not. CI only verifies that all generated files were committed and never rewrites them silently.

Keep versions in `Tuist/Package.swift` exact so CI uses the same versions in both resolver modes. The root `Package.swift` is the public library manifest and has its own independent `Package.resolved`; compatible version ranges there are intentional.

Dependency caching is CI-only and requires no local setup or cleanup. CI caches only SwiftPM downloads, never `Tuist/.build` or DerivedData, and publishes a cache only after a successful Registry resolution on `main`. Local `make project` uses the normal system SwiftPM cache; the optional downloaded Tuist distribution is stored under the standard macOS `~/Library/Caches/WrapKit` location.
