# WrapKit agent guide

Generic foundation framework consumed by DesignSystem and NUR.Features. No dependency on these packages, MyO business rules, or branded resources.

## Workflow

- This file is the self-contained project guide. All paths are relative to this repository unless stated otherwise; no external prompt or sibling documentation directory is required.
- Before coding, identify affected modules/layers, public contracts, consumers, required imports, and validation. Read relevant local implementations and manifests; reuse unchanged context already read in this task.
- Inspect affected targets, nearby implementations/tests, and `git status --short`. Preserve unrelated changes and keep scope focused.
- Use local project configuration as the source of truth. Verify paths, imports, target names, dependencies, deployment versions, and commands against current manifests, Tuist helpers, Makefile, and generator configs. Existing violations do not justify new ones.
- These are separate repositories. Editing a sibling checkout does not replace an exact-pinned SPM dependency.
- Use constructor injection and existing protocols; no service locators or new singletons. Keep imports within declared target dependencies and SPM/Tuist definitions consistent; avoid cycles.
- Preserve internal exact pins. New third-party dependencies, pin changes, and releases need explicit authorization unless already included in the task. Never run `make patch-tag` as validation.

## Swift and concurrency

- Follow local `.swiftlint.yml` and neighboring style. Prefer one primary type per file and separate substantial extensions.
- Capture self weakly in escaping callbacks that could outlive their owner or create a retain cycle.
- No force unwraps, `try!`, unsafe force casts, private Apple APIs, or undocumented Swift attributes. Keep `fatalError` out of production paths except established unsupported `init(coder:)` stubs.
- Preserve existing Combine flows. Store subscriptions in `cancellables: Set<AnyCancellable>`; use `[weak self]` when capturing self in escaping Combine closures.
- Use Swift Concurrency for new concurrent work, not direct `DispatchQueue` or `OperationQueue`. Deliver UI changes through `@MainActor` or existing MainQueueDispatchDecorator. Do not rewrite generator-owned GCD implementations incidentally.
- Check compiler and deployment compatibility before adopting modern APIs. Current SPM platforms are iOS 15, macOS 10.15, tvOS 15, watchOS 8; verify individual Tuist targets. Do not raise deployment versions for cosmetic API changes.
- Prefer locale-aware formatting for user-visible values and `localizedStandardContains()` for human text search; preserve exact matching for identifiers/protocol data.
- Never commit secrets or expose credentials in logs, fixtures, or reports.

## Generated code and validation

- Never hand-edit generated Xcode projects/workspaces, `Generated/`, `Derived/`, or generated Swift files outside those folders. Edit source protocols, resources, templates, or manifests, then regenerate.
- New output protocols need generated WeakRef, MainQueueDispatchDecorator, and spies. Follow nearby annotations; verify generator output.
- Some generated files are tracked. Preserve the policy established by `git ls-files` and `.gitignore`; do not delete tracked output or force-add ignored artifacts.
- Project generation is not compilation. For Swift changes, discover actual schemes/destinations, build affected targets, and run relevant tests with Xcode/`xcodebuild`; run applicable SwiftLint checks.
- Test changed behavior and regressions. For documentation-only changes, check content, paths, and diff without building.
- Inspect the final diff and run `git diff --check`. Report failed/unavailable checks and remaining validation honestly.

## Task report

Write relevant files under `reports/<task_name>/` in this repository: `done.md` (implementation), `files-modified.md` (action/path/reason table), `how-to-check.md` (actual results and manual steps). Add `risks.md` and `improvements.md` only when useful. Use the task ID or a short descriptive name; for multi-repository tasks, keep each repository’s report local and identify cross-repository dependencies by name. Preserve others' reports. If the directory is unavailable, disclose this and report in the response. Reply in the user's language with changes, validation, and limitations.

## Structure and architecture

Paths below are relative to this repository:

- `WrapKitCore/Sources/WrapKitCommon/`: shared abstractions, presentation contracts, services/storage, extensions/helpers.
- `WrapKitCore/Sources/{WrapKitAuth,WrapKitNetworking,KeychainSwift}/`: auth/network/storage infrastructure.
- `WrapKitCore/Sources/WrapKitUI/`: UIKit/SwiftUI base classes, wrappers, adapters.
- `WrapKitCore/TestUtils/`: public WrapKitTestUtils doubles. `WrapKitCore/Tests/`: tests.
- `WrapKitGame/Sources/`: separate WrapKitGame product. `SwiftUIApp/`: example app.

Read actual definitions and generic constraints before changing Service, Storage, HTTPClient, output protocols, WeakRef/MainQueueDispatchDecorator, `ViewController<ContentView>`, or diffable wrappers.

Keep data/domain abstractions independent of UIKit/SwiftUI. Put UI in the existing UI layer with platform guards; UIKit is not forbidden throughout the framework. Never import DesignSystem, MyOAssets, MyOStrings, or feature modules. Consumers provide branded strings/colors/images; do not introduce NurAssets/NurStrings dependencies here. Avoid MyO prefixes and feature-specific Flow/Factory APIs in generic infrastructure.

## Compatibility and behavior

- Preserve public source compatibility, generic constraints, error models, and Combine publisher semantics.
- For service/storage/network changes, test relevant success, failure, cancellation, event ordering, object lifetime, and delivery context. Use deterministic doubles, not live network requests.
- Production targets must not depend on XCTest or TestUtils.
- Maintain platform guards and validate affected platforms. Do not restrict generic contracts to iOS without need.
- Current Package.swift declares Lottie and Kingfisher; verify each target’s declared dependencies before importing a library.
- WrapKit.podspec contains legacy versions/platforms/source paths inconsistent with SPM. Do not claim CocoaPods compatibility from it; treat CocoaPods support changes as separate scope.

## UI utilities

- Preserve generic styling and configuration; consumers supply brand tokens.
- Support Dynamic Type and accessible labels. Prefer semantic buttons over tap gestures and container sizing over `UIScreen.main.bounds`.
- For SwiftUI additions, use reusable View structs, stable list identity, and `@MainActor` for UI-driving observable models. Avoid unnecessary AnyView.
- Adopt modern SwiftUI/Swift APIs only where compiler/deployment permits; preserve older-platform fallbacks and existing Combine adapters.

## Commands and tests

Run from this repository root:

| Command | Effect |
| --- | --- |
| `make run-sourcery` | Decorators, proxies, SwiftUI adapters, spies; first deletes Generated folders |
| `make project` | Sourcery + Tuist setup + workspace generation |
| `make build` | Sourcery + clean/install; neither compilation nor tuist-generate |
| `make tuist-generate` | Generate project using prepared dependencies |

Check for unfinished changes in Generated folders before regeneration. No `sourcery` or `swiftgen` targets exist.

SPM test target: WrapKitTests. Tuist manifest: `WrapKitCore/Project.swift`. Test plan: `WrapKitCore/Tests/WrapKit-Package.xctestplan`. Run UIKit tests with Xcode/`xcodebuild`, an iOS simulator, and the appropriate test host; macOS `swift test` only validates compatible code.

For public API changes, check an affected consumer when local integration is available. Disclose when exact pins prevent testing local changes without additional setup.

## Core API reference

| Area | Actual source location under WrapKitCore/Sources | Responsibility |
| --- | --- | --- |
| Service | WrapKitCommon/Service/Service.swift | Generic request/response publisher and ServiceError |
| Storage | WrapKitCommon/Storage/Storage.swift | Optional model reads, writes, clearing and observation |
| Persistence | WrapKitCommon/Storage/ | InMemoryStorage, UserDefaultsStorage, KeychainStorage, CoreDataStorage |
| Service/storage composition | WrapKitCommon/StoredService/StoredService.swift | StorageServiceComposition and ServiceStorageComposition |
| HTTP transport | WrapKitNetworking/HTTPClient.swift and URLSession/ | HTTPClient and URLSessionHTTPClient |
| HTTP decorators | WrapKitCommon/HTTPClient/ and WrapKitAuth/ | Request enrichment, storage/cancellation/completion and authentication |
| Network logging | WrapKitNetworking/Logger/ | LoggerHTTPClient and related logging support |
| Analytics | WrapKitCommon/Analytics/ | AnalyticsTracker abstraction |
| Input masks | WrapKitCommon/MaskedInput/ | Generic input masking |
| Presentation/UI | WrapKitCommon/Presentation/ and WrapKitUI/ | Outputs, base views/controllers, tables and adapters |

The current contracts are:

```swift
public protocol Service<Request, Response> {
    associatedtype Request
    associatedtype Response
    func make(request: Request) -> AnyPublisher<Response, ServiceError>
}

public protocol Storage<Model>: Hashable {
    associatedtype Model
    var publisher: AnyPublisher<Model?, Never> { get }
    func get() -> Model?
    @discardableResult
    func set(model: Model?) -> AnyPublisher<Bool, Never>
    @discardableResult
    func clear() -> AnyPublisher<Bool, Never>
}
```

ServiceError distinguishes message, internal, connectivity and cancelled cases. Preserve those distinctions when wrapping transport failures. Storage's optional model represents an absent/cleared value; do not silently turn nil into a fabricated model. Preserve Bool write/clear results and Hashable semantics.

The shared AnyPublisher `.handle(onSuccess:onError:onCancel:onCompletion:)` implementation currently schedules delivery and subscribes internally. Review that behavior before composing an additional sink: a second subscription can repeat upstream work. Existing internal scheduling/retention machinery is compatibility-sensitive; changes need tests for cancellation, lifetime, ordering and subscription count.

Use existing map/flatMap/catch and composition helpers. Fallbacks must be deliberate and preserve failure semantics; do not globally convert services to Never or silently swallow errors.

### UI foundation and protocol ownership

- `ViewController<ContentView>` provides a typed content view/lifecycle bridge. View base classes and extensions supply construction/layout hooks; check the actual name before assuming a ViewUIKit type exists.
- TableView/TableViewCell<T> and diffable wrappers provide reusable list infrastructure. Preserve reuse/reset behavior, identity and UI-thread delivery.
- HeaderOutput/TableOutput/RefreshControlOutput/LifeCycleViewOutput can be declared in UI source files, while loading/toast use cases also exist in Common/Presentation. A protocol's name does not guarantee platform independence; inspect imports/guards before using it in a common layer.
- WeakRef proxies prevent presenter-to-view retention cycles; MainQueueDispatchDecorator handles delivery; SwiftUI adapters expose presentation state; spies observe calls for tests.
- Branded Nur navigation/shimmer/card styles belong in DesignSystem. The foundation should accept configuration without importing those styles.

### Packages and dependencies

WrapKit exports WrapKit, WrapKitGame, and WrapKitTestUtils. WrapKitGame depends on WrapKit and Lottie. WrapKitTestUtils depends on WrapKit and links XCTest; tests also include resource fixtures.

Lottie supplies animation support; Kingfisher supplies image loading/caching. CryptoSwift, DeviceKit and PhoneNumberKit are not current root package dependencies; consuming NUR.Features declares them directly where needed. Do not restore old transitive dependencies incidentally.

## Extending the framework

1. Identify the smallest reusable contract and its affected consumers/platforms.
2. Preserve public names, constraints and publisher semantics unless the requested change explicitly requires migration.
3. Place implementation in the corresponding Common, Networking, Auth or UI area; expose only needed API.
4. Add deterministic tests/doubles in Tests/TestUtils and resource fixtures in the established test resources.
5. For protocol changes, regenerate all corresponding wrappers and inspect emitted signatures.
6. Verify platform compilation and relevant UI/snapshot tests; check consumers using an explicit local integration or agreed release.
7. Document incompatible behavior and migration needs; do not publish a tag automatically.

## WrapKit generation and CI details

- All four Sourcery scripts, including SpyGenerator, live in `Scripts/Sourcery/`. The Makefile's regeneration target removes Generated folders first.
- `WrapKitCore/Project.swift` defines library, TestUtils, tests and a test-host app; `WrapKitGame/Project.swift` and `SwiftUIApp/Project.swift` define additional projects.
- GitHub Actions configuration is `.github/workflows/ci.yml`, not GitLab CI. It installs/selects build tools, runs make project and tests `WrapKit.xcworkspace` with scheme `WrapKit` across its simulator matrix.
- CI collects snapshot failures (origin/diff/new images). Investigate rendering changes before updating baselines, and retain useful failure artifacts.
- Use the configured Xcode/Tuist versions when reproducing CI. Runner version/device changes are not permission to raise library deployment minimums.

## Build configuration and release model

- `Workspace.swift` selects Tuist projects. Each `Project.swift` defines source globs, targets, dependencies, schemes, resources, and build settings.
- `Tuist/ProjectDescriptionHelpers/Project+Templates.swift` centralizes project/path/name helpers and shared settings. Do not infer target spelling or deployment settings from directory names.
- Root `Package.swift` describes the SPM package consumed by other projects. `Tuist/Package.swift` controls Tuist dependency resolution/settings; it is not merely a plugin list. Preserve their intended dependency/product-type alignment.
- `Package.resolved` files lock resolved dependency graphs. Do not refresh unrelated pins as a side effect of a documentation or source-only change.
- Prerequisites are Xcode/command-line tools, Tuist, Sourcery, SwiftLint, and SwiftGen where resources are generated. Check installed versions against repository configuration before diagnosing a build failure.
- Preserve job-specific `XDG_CACHE_HOME` and DerivedData isolation. Avoid broad cleanup of other jobs' caches, simulators, or processes.
- CI definitions are executable configuration, not local setup scripts: do not replay credential setup, global Git configuration, publishing, or cleanup steps indiscriminately.
- Each repository has its own release cycle. Package versions come from release tags and consumer pins, not an editable package-version field in Package.swift. NUR.Features uses a 0.x tag series, DesignSystem 1.x, and WrapKit 3.x in current release recipes. Read the recipe before an authorized release.
- For an authorized cross-package release, validate the producer, publish the agreed version, then update intended consumer pins consistently. Report consumers not tested or updated.

## Generator contracts

| Generator | Responsibility |
| --- | --- |
| MainQueueDispatchDecorator | Forward output/navigation calls on the UI delivery context |
| WeakRefVirtualProxy | Forward output calls without retaining the view |
| SwiftUIAdapterGenerator | Bridge output-driven presentation to SwiftUI observation |
| SpyGenerator | Record protocol calls and arguments for tests |

Generated wrappers are infrastructure, not a place for business rules. Inspect source templates when a protocol change is not reflected in output; verify generated method signatures and target inclusion. A successful generator process alone does not establish that every expected wrapper was emitted.

## Additional coding and completion rules

- Use `guard let`, `if let`, or explicit defaults for optionals. Handle thrown errors intentionally; do not suppress failures solely to pass a build. Use `@discardableResult` only for intentionally ignorable results.
- Never access private symbols via string selectors. Guard newer APIs with availability checks and compatible fallbacks; avoid deprecated APIs in new code unless compatibility requires them.
- Prefer `foregroundStyle`, shape clipping, `bold()`, modern scroll indicators, and data-driven SwiftUI navigation where supported. Keep deployment-compatible observation and modifier overloads; do not impose newer APIs globally.
- Before completion, check layer boundaries, declared imports, naming, weak ownership, UI delivery, generated outputs, localization, affected consumers, and actual build/test results.
- In `done.md`, identify new/changed types, methods, protocols, and wiring. In `files-modified.md`, include created, modified, and deleted files. In `how-to-check.md`, separate executed commands/results from proposed manual steps and specify expected behavior. Risks should include impact and mitigation; improvements should remain outside implementation scope.
