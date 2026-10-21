# MYO-7698: SwiftUI header и glass-кнопки

В ветке `DOM-5794` исправлены два дефекта WrapKit, воспроизведённых при проверке SwiftUI-экранов NUR.Features.

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

Output-контракты, replay-механизм, generated-адаптеры и dependency pins не менялись. Коммитов, пуша и выпуска версии нет. Точный pin WrapKit в NUR.Features не подхватывает изменения соседнего checkout автоматически.

Итог изолированного UI-прогона: 2 теста, 0 ошибок. Финальный запуск button/header snapshot-, state- и replay-тестов завершён: 154 из 154 прошли. Baseline-файлы не менялись. Результаты относятся к указанному в `how-to-check.md` iPhone 17 Pro / iOS 26.2; проверка остальных платформ этим прогоном не подтверждена.
