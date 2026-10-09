# SDK privacy

The Swift package and Tuist framework manifests explicitly include a separate `PrivacyInfo.xcprivacy` resource for each production target:

| Target | Source resource | Required reason |
| --- | --- | --- |
| WrapKit | `WrapKitCore/Sources/Resources/PrivacyInfo.xcprivacy` | UserDefaults `C56D.1`: the storage wrapper runs when its consumer requests a read or write. |
| WrapKitGame | `WrapKitGame/Sources/Resources/PrivacyInfo.xcprivacy` | UserDefaults `CA92.1`: game preferences remain in the host app's defaults domain. |

Game language storage reads an app-owned `AppleLanguages` override from the host app's persistent domain. Without an override it uses `Locale.preferredLanguages`; it does not read the system's global defaults domain. Writes and clearing affect the app's override.

The SDK declares no tracking and no data collection for its own purposes. An app remains responsible for its own API use, configured networking or analytics destinations, and other dependencies. These manifests do not describe client-provided analytics implementations. Dependency manifests, including Kingfisher and Lottie, must remain bundled as well.

The source audit on 2026-10-04 found UserDefaults access in these two targets. No direct calls to the required file-timestamp, disk-space, system-boot-time, or active-keyboard APIs were found. Loading animations use `CACurrentMediaTime`, which is not listed in Apple's current required-reason API categories. Recheck the audit when code or Apple's API list changes.

## Verify and publish

1. Validate both property lists with `plutil -lint` and inspect `swift package dump-package`: both resources must belong to their respective targets.
2. Build an iOS app that consumes both products. Confirm that `WrapKit_WrapKit.bundle/PrivacyInfo.xcprivacy` and `WrapKit_WrapKitGame.bundle/PrivacyInfo.xcprivacy` are present in its Release archive and contain the expected declarations. SwiftPM generates a separate `Bundle.module` accessor for each target; no public resource accessor is necessary for privacy metadata.
3. Run `WrapKitTests/GameLanguageStorageTests` and the consumer app's tests. These tests preserve the test host's original language preference and process-local argument domain; they never write system global preferences. The main branch has other API changes since tag `3.1.928`, so a new tag also requires checking consumer compatibility; adding resources alone does not establish that compatibility.
4. Commit and publish an approved SDK release, then update the consumer's exact version and lockfile. Local files do not modify an already published tag. Keep SDK resources in the archive and generate the aggregate privacy report before distribution.

App Store Connect acceptance must be checked on the submitted signed archive. Source checks and a local unsigned build do not establish upload acceptance.

## Verified on 2026-10-04

- Both manifests passed `plutil -lint`; `swift package dump-package` confirmed their explicit target resources and the game dependency of `WrapKitTests`.
- All 3 `GameLanguageStorageTests` passed on iPhone 17 Pro / iOS 26.3.1 through the `WrapKit-Package` scheme with the package test plan's Thread Sanitizer enabled.
- The simulator build contained both SDK privacy resource bundles with the expected reasons. Both target-specific `Bundle.module` accessors compiled without conflicts.
- This patch has not been published as a version. A consumer pinned to an older version still needs an approved new SDK release before these resources reach its production archive.

## Apple documentation

- [Required-reason API categories and approved reasons](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype)
- [Declaring API use separately for an app and an SDK](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api)
- [Explicit Swift package privacy resources](https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk)
- [Reading a specific UserDefaults persistent domain](https://developer.apple.com/documentation/foundation/userdefaults/persistentdomain(forname:))
