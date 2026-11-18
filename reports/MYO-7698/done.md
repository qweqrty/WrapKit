# MYO-7698: SwiftUI header, glass-кнопки и refresh

В ветке `DOM-5794` исправлены дефекты WrapKit, воспроизведённые при проверке SwiftUI-экранов NUR.Features. Header/glass опубликованы пользователем в 3.1.993; дополнительная правка refresh ниже пока локальная, без коммита и публикации.

## Header после UIKit push/pop

В `View+NavigationHeader.swift` native leading- и trailing-кнопки читают актуальный callback из наблюдаемого state непосредственно при нажатии. Ранее toolbar мог удерживать снимок модели с уже отозванным callback после повторных push/pop. Для rich trailing-кнопки сохранена nil-семантика action.

Добавлены `HeaderAfterPopFixture`, `HeaderAfterPopUITests` и две проверки в `SUINavigationBarParityTests`. Fixture использует внешний `UINavigationController`, отдельные `SUIHostingController` с `NavigationStack` и обновляет trailing-кнопку через `HeaderOutput` при каждом появлении корневого экрана. UI-тест проверяет выполнение callback до перехода и после пяти возвратов: итоговый счётчик — `Presses: 6`.

## Прокрутка от glass-кнопки

В `SUIButtonView` убран `simultaneousGesture` с `DragGesture(minimumDistance: 0)`, который перехватывал вертикальный жест родительского `ScrollView`. Состояние нажатия отслеживается через обычный `.onLongPressGesture(minimumDuration: .infinity, maximumDistance: 10, pressing: …)`. Gesture только наблюдает press/release; действие выполняет native `Button`.

Сохранены нативные glass button styles, `pressedColor`/`pressedTintColor` и анимация `.shrink`. `isGlassPressed` переведён в `@State` и сбрасывается при отключении кнопки, удалении action и исчезновении view.

Добавлены `GlassButtonScrollFixture` и один UI-сценарий для трёх режимов: native, WrapKit, WrapKit с `.shrink`. Во всех режимах drag прокручивает родителя без action, tap вызывает action один раз, удержание с отпусканием — второй раз. Сохранение glass, красного pressed-состояния и shrink до 95% подтверждено основным исполнителем по видеокадрам финального прогона.

## Инфраструктура и границы

`WrapKitTestHost` подключён к WrapKit, добавлены target/scheme `WrapKitUITests` и выбор fixture через launch arguments. Каждый UI-тест проверяет один сценарий и сохраняет снимки экранов.

Временные варианты композиции двух `buttonStyle`, `simultaneousGesture(LongPressGesture)` и переноса gesture на label отвергнуты и не входят в итоговый production-код. UIKit gesture bridge и вложенная декоративная кнопка не добавлялись.

Первоначальная правка header/glass не меняла Output-контракты, replay-механизм и generated-адаптеры. В дополнительной правке refresh изменены шаблон и generated-адаптер; public `onRefresh`/`$onRefresh` сохранены. Dependency pins не менялись. Точный pin WrapKit в NUR.Features не подхватывает изменения соседнего checkout автоматически.

Итог изолированного UI-прогона: 2 теста, 0 ошибок. Финальный запуск button/header snapshot-, state- и replay-тестов завершён: 154 из 154 прошли. Baseline-файлы не менялись. Результаты относятся к указанному в `how-to-check.md` iPhone 17 Pro / iOS 26.2; проверка остальных платформ этим прогоном не подтверждена.

## Refresh: дополнительное исправление 21.10.2026

В реальной фабрике деталей тарифов main/options добавляют действия через `onRefresh?.append`, update — через `display(appendingOnRefresh:)`. Последующий direct append отзывал callback update, который оставался в массиве: выполнялись только main/options.

Публичный массив теперь содержит исходные callbacks, как UIKit. UI/replay получают отдельный отзываемый snapshot. Замена/очистка отключает старые UI/event copies и освобождает их owners; внешние копии публичного массива остаются обычными UIKit-замыканиями. `nil` не превращается в массив через display, порядок/nil-слоты/дубликаты сохранены. State читает актуальный snapshot, а один refresh выполняет локальную копию исходного массива до конца, даже если первое действие меняет список. Старый consumer после remount больше не читает/вызывает callbacks.

Добавлены 8 regression-тестов в `SUIRefreshControlStateModelTests`. Шаблон `Scripts/Sourcery/SwiftUIAdapter.stencil` изменён первым, адаптер получен штатной регенерацией. Обходов в Features Presenter нет.

Проверки Xcode 27.1:

- Отрицательный контроль: новая mixed direct/display проверка на исходных production adapter/state из 3.1.993 падает с `[main, options]` вместо `[main, update, options]` до mount, после mount и remount. `WKRefreshBefore.xcresult`, exit 65. Исправленные исходники затем восстановлены.
- Исправленный код, iPhone 17 Pro / iOS 26.2: 177/177 PASS — 56 UIKit button snapshots, 31 SwiftUI button snapshots, 19 header update snapshots, 15 button state, 21 header parity, 23 refresh, 12 replay/lifetime. `WKRefreshAndSnapshots.xcresult`, exit 0.
- iPhone 16 Pro / iOS 18.5: 35/35 refresh/replay PASS. `WKRefresh18.xcresult`, exit 0.
- Baseline не перезаписывались; generator, SwiftLint и `git diff --check` прошли. Первый compile-прогон нового теста остановился на неоднозначном `weakReferenced`; исправлено явным типом `any RefreshControlOutput`, как в feature wiring. Неуспешный лог сохранён, не включён в PASS.

Артефакты: `/private/tmp/MYO-7698-review-fixes.WzOVNT`. Для распространения исправления требуется публикация WrapKit и согласованное обновление pins DesignSystem/Features; следующий тег не придумывался.

Интеграция: Features с локальным исправленным WK и опубликованным DS 1.0.1690 собран штатным Tuist. 2/2 UI PASS на iOS 18.5 и 4/4 на iOS 26.2. Disconnect trace после действия содержит main/details → update/getSubUser → options/getTariffOptions; в исходном WK средний запрос пропускался. Sub-user fixture здесь отсутствует (404), поэтому успешное child-storage обновление этим не заявляется. Временный local override после проверки удалён; remote install/generate прошли. Точные результаты/границы — `NUR.Features/reports/MYO-7698/control-fixes.md`.
