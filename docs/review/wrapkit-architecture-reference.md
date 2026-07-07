# WrapKit Architecture Reference

Reference для ревью архитектуры WrapKit и для написания общего review-agent.

## Роль репозитория

WrapKit - переиспользуемая Swift UI/infrastructure библиотека для нескольких приложений и feature-модулей.
Здесь не должно быть продуктовой логики, backend DTO решений конкретной фичи, routing сценариев приложения или UI-хаков под один экран.

Главный принцип ревью: фиксить контракт общего компонента, а не подгонять один downstream screenshot.

## Фактическая структура

`Package.swift` объявляет один основной target `WrapKit`, который собирает весь `WrapKitCore/Sources` и заявляет несколько платформ:

- iOS 15+
- macOS 10.15+
- tvOS 15+
- watchOS 8+

Из-за одного target границы слоев не enforce-ятся компилятором. Их нужно проверять ревьюом по папкам, импортам и API.

## Слои

### Low-level / platform-agnostic

- `WrapKitCommon`
- `WrapKitNetworking`
- `WrapKitAuth`
- value types, storage, service abstractions, HTTP clients, decorators, pure presenters.

Правило: новый код здесь должен оставаться Foundation/Combine-level. UIKit/SwiftUI допустимы только если это уже существующий adapter/compatibility файл с явной причиной.

### UI common

- `WrapKitUI/Common`
- общие UI value types, которые не должны зависеть от конкретного UIKit/SwiftUI implementation.

Правило: это место для платформенно-нейтральных UI-моделей, а не для UIView/UIViewController поведения.

### UIKit

- `WrapKitUI/UIKit`
- UIKit views, view controllers, presentation controllers, cells, screen-level reusable UI.

Правило: UIKit-specific поведение должно оставаться здесь и быть guarded через `canImport(UIKit)`/availability, если файл участвует в multi-platform target.

### SwiftUI

- `WrapKitUI/SwiftUI`
- SwiftUI views/adapters.

Правило: SwiftUI adapters не должны менять контракт базовых output-моделей ради удобства одного SwiftUI клиента.

### Generated

- `Generated` files вокруг output protocols: spy, weak proxy, main queue dispatch, SwiftUI adapters.

Правило: если меняется output protocol, проверить generated файлы и sourcery workflow. Не править generated вручную без понимания генерации.

## Направление зависимостей

Правильное направление:

```text
Networking/Auth/Common -> UI Common models -> UIKit/SwiftUI implementations -> downstream apps
```

Запрещенное направление:

```text
Common/Networking/Auth -> UIKit screen behavior
WrapKit -> product feature behavior
Base component -> downstream-specific title/image/color inference
```

Если изменение выглядит как product behavior, оно должно жить в `NUR.Features`/`NUR.DesignSystem`.
Если изменение чинит общий контракт UI-компонента, оно может жить в WrapKit.

## Platform agnostic contract

Проверять:

- Новый low-level код не импортирует UIKit/SwiftUI/AppKit без явного adapter-смысла.
- UIKit-only файлы имеют `#if canImport(UIKit)` если target мультиплатформенный.
- iOS 26-specific API закрыт availability guard и не меняет iOS 18.x поведение без задачи.
- macOS/tvOS/watchOS сборки не ломаются из-за незащищенного UIKit-only символа.
- Общие модели используют neutral types (`EdgeInsets`, `Color`, `Font`, resource wrappers), а платформенные конверсии лежат рядом с UI implementation.

## Component API contract

WrapKit component API должен быть predictable:

- `display(model: nil)` скрывает компонент, если это established contract.
- Shimmer/loading не смешивается с `nil` model, если компонент или screen уже разделяет эти состояния.
- Если caller передал точный inset/size/radius/color, компонент обязан уважать точное значение.
- Public/open API не меняется молча: новые callbacks, defaults и side effects должны иметь четкую семантику.
- Компонент не должен угадывать продуктовую логику по title/image/color/string.
- События должны означать ровно то, как они названы. Например, `onTapOutside` - tap вне sheet, а не любой dismiss.
- Callback dismissal должен учитывать completed/cancelled transition, programmatic dismiss и gesture dismiss отдельно.

## UI / layout rules

Проверять:

- Layout чинится constraints/contract-ом компонента, а не one-off костылем в потребителе.
- UIStackView/layoutMargins/insets не должны зависеть от случайного intrinsic content size.
- `systemLayoutSizeFitting` можно использовать только если понятен весь sizing path для multiline/low-priority content.
- Corner radius и border должны применяться к фактически rendered layer/path.
- iOS 18.5 и iOS 26+ могут отличаться из-за UIKit defaults; отличия должны быть покрыты snapshots или явно описаны.

## Snapshot / tests

Snapshot tests - часть публичного API WrapKit UI.

Минимальный критерий:

- UI component changed -> narrow snapshot test.
- Behavior/callback changed -> unit/integration test or explicit manual scenario if test infrastructure не позволяет.
- iOS-version-specific behavior -> проверить iOS 18.5 и iOS 26+ snapshots, когда возможно.
- Не record-ить snapshots, пока визуальный результат не принят.

## Downstream impact

WrapKit обычно идет по цепочке:

```text
WrapKit -> NUR.DesignSystem -> NUR.Features -> algaios
```

Review должен спрашивать:

- Это изменение действительно нужно в WrapKit, а не в DesignSystem/Features?
- Какие downstream компоненты используют этот public API?
- Нужно ли обновить snapshot в WrapKit и UI screenshot в Features?
- Не поменялся ли default behavior для всех потребителей?

## Current architecture review

### Сильные стороны

- Есть четкая папочная структура: Common/Networking/Auth/UI.
- Большинство UI-компонентов построены через `PresentableModel` + `Output`.
- Есть snapshot test surface для UIKit components.
- Есть generated spies/proxies/adapters, что помогает тестировать output contracts.

### Системные риски

- Один SPM target не защищает слои компилятором. Ревьюер обязан проверять imports и direction вручную.
- В `WrapKitCommon/Presentation` уже есть platform-specific adapters/loading views. Это existing debt, его нельзя расширять без явной причины.
- Generated adapters могут незаметно протащить UIKit/SwiftUI в protocol-level API, если output protocol спроектирован слишком platform-specific.
- Public/open API changes имеют большой blast radius: DesignSystem, Features, algaios.
- Layout bugs в shared components часто проявляются только на продуктовых данных; нужен маленький reproducer snapshot в WrapKit.

### Критерии для текущих типов изменений

BottomSheet:

- API callbacks должны быть low-level и reusable, без слов типа `skipped`, `bonus`, `cabinet`.
- `onTapOutside` должен срабатывать только при tap вне sheet.
- `onPanToDismiss` должен срабатывать только если dismiss реально завершился из pan gesture.
- Programmatic dismiss не должен маскироваться под tap/pan.
- Disabled `tapToDismissEnabled` / `panToDismissEnabled` должен выключать не только dismiss, но и соответствующий callback.
- Нужны тесты или manual сценарии: tap outside, pan completed, pan cancelled, programmatic dismiss, disabled tap/pan.

NavigationBar:

- Header output не должен неявно управлять product routing.
- Если custom navigation bar синхронизирует `navigationItem.title`, это side effect на owning `UIViewController`.
- Такой side effect должен быть либо явно оправдан системным UIKit behavior, либо быть opt-in/configurable.
- Нужно проверить back menu / long press / interactive pop на iOS 18.5 и iOS 26+.

## Review verdict rules

- `Critical`: ломается сборка, публичный API стал несовместим, platform guard отсутствует и ломает платформу, явный downstream regression.
- `Major`: нарушен reusable component contract, product-specific behavior попал в WrapKit, нет test/snapshot для shared UI behavior, callback semantics неверные.
- `Minor`: локальный style smell, naming/spacing, небольшая упрощаемость без риска поведения.
- `Test gaps`: поведение может быть верным, но нет snapshot/unit/manual evidence.
