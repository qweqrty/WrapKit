# WrapKit: локальные договорённости

Дополнение к корневому `AGENTS.md`, архитектурному контракту и профилю WrapKit. Пути относительны корню репозитория; параметры и API сверяй с текущими исходниками.

## Слои и совместимость

- `WrapKitCore/Sources/WrapKitCommon/` — общие контракты, presentation-модели, Service/Storage и helpers; `WrapKitAuth/`, `WrapKitNetworking/`, `KeychainSwift/` — auth/network/storage-инфраструктура; `WrapKitUI/` — native UI и bridges.
- Domain/data-контракты остаются независимыми от UIKit/SwiftUI. Native UI внутри UI-слоя допустим с platform guards. Само имя `HeaderOutput` или `TableOutput` не доказывает платформенную независимость: проверяй imports/guards исходного определения.
- Не импортируй DesignSystem, MyOAssets/MyOStrings или Features. Без Nur-ресурсов, MyO-префиксов и продуктовых Flow/Factory. Потребитель передаёт брендовые значения через конфигурацию.
- Сохраняй public source compatibility, generic constraints, error cases, Combine-семантику и поддерживаемые платформы. Не сужай общий контракт до iOS, не повышай минимальную ОС под CI destination.
- `WrapKitCore/TestUtils/` — публичные test doubles; production target не должен зависеть от XCTest/TestUtils. WrapKitGame — отдельный продукт с собственными sources/resources.
- Наличие legacy `WrapKit.podspec` не доказывает актуальную CocoaPods-совместимость: source paths/platforms и сборку нужно проверять отдельно от SPM/Tuist.

## Контракты, чувствительные к регрессиям

- `Service.make(request:)` возвращает publisher с `ServiceError`, не глобально `Never`. Сохраняй различия message/internal/connectivity/cancelled, не глуши ошибки общим fallback.
- `Storage.publisher` публикует optional model; nil означает отсутствующее/очищенное значение. Не превращай его в выдуманную модель; сохраняй результаты write/clear и Hashable-семантику.
- В `WrapKitCommon/Service/Service.swift` helper `.handle(...)` подписывается внутри. Прежде чем добавлять `.sink`, проверь subscription count: второй subscriber может повторить upstream work. Изменение delivery/retention требует проверки lifetime, отмены, порядка и числа завершений.
- Для HTTP/auth/cancellation сохраняй completion, late-response и session-поведение. Проверяй детерминированными doubles, не живой сетью.
- Typed `ViewController<ContentView>`, diffable/table wrappers и reuse/reset — публичная инфраструктура. Проверь фактические hooks/constraints; не изобретай несуществующий базовый тип по памяти.

## Генерация и тесты

| Команда из корня | Назначение |
| --- | --- |
| `make run-sourcery` | MainQueue/WeakRef/SwiftUI adapters/spies; удаляет Generated перед регенерацией |
| `make project` | Проверка locks/toolchain, генераторы, dependencies и Tuist generation |
| `make build` | Подготовка generators/dependencies, не компиляция и не полный generate |
| `make tuist-generate` | Generation с подготовленными dependencies |
| `make ci-project` | CI setup с проверкой lock-файлов; прочитай Makefile перед запуском |

- Все Sourcery scripts/spies — `Scripts/Sourcery/`. Перед регенерацией проверь Generated на чужие изменения. Соблюдай selectors/templates и проверяй emitted signatures.
- Актуальный Makefile может разрешать Registry/Git и обновлять dependency locks. Не обновляй их попутно; используй предусмотренный verification-режим, когда нужны неизменные locks. Не копируй hardcoded toolchain из старых сообщений.
- Тесты — `WrapKitCore/Tests/`, SPM test target — WrapKitTests, Tuist manifest — `WrapKitCore/Project.swift`, test plan — `WrapKitCore/Tests/WrapKit-Package.xctestplan`. Для UIKit/snapshots нужен iOS simulator и test host; macOS `swift test` не доказывает UI-совместимость.
- Релевантные unit и snapshots обязательны по профилю WrapKit. Связывай setup/model и последовательные display/action с реально видимым origin/new/diff; CI green не заменяет просмотр. Не переписывай baseline/tolerance без выяснения причины.
- GitHub CI — `.github/workflows/ci.yml`. Scheme/workspace и текущую simulator matrix прочитай там; failure artifacts содержат origin/diff/new. Сохраняй полезные доказательства вне репозитория.
- Для публичной правки проверь реального потребителя и реально подключённый revision; sibling checkout не меняет exact pin. Не заявляй тест интеграции, если потребитель собрал старую версию.
