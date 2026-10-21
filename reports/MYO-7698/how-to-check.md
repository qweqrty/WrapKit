# Проверка MYO-7698

## Выполнено

Основной исполнитель выполнил финальный изолированный UI-прогон на iPhone 17 Pro / iOS 26.2, Xcode 27.1 (`27A9269`, `/Users/sli/Downloads/Xcode.app`). Simulator UDID: `75DBAB34-4A2F-40D9-8C49-C0C4AD689113`.

| Проверка | Результат |
| --- | --- |
| `GlassButtonScrollUITests/test_draggingFromGlassButtonScrollsWithoutActivatingIt_thenTapActivatesOnce` | PASS: native, WrapKit и WrapKit + shrink; drag перемещает кнопку вверх более чем на 80 pt без action, затем tap даёт `Presses: 1`, hold/release — `Presses: 2` |
| `HeaderAfterPopUITests/test_primaryHeaderActionWorksBeforeAndAfterUIKitPushPop` | PASS: action до push и после пяти pop; итог `Presses: 6` |
| Итог `WKReprosFinal.xcresult` | 2 теста, 0 ошибок; `TEST SUCCEEDED` в `wk-repros-final.log` |
| Итог `WKButtonHeaderSnapshotsFinal.xcresult` | 154 теста, 0 ошибок; `TEST SUCCEEDED` в `wk-button-header-snapshots-final.log`, baseline-файлы не менялись |
| Визуальная проверка glass | Основной исполнитель проверил native glass, красный pressed-color и shrink до 95% по видео финального прогона |
| SwiftLint header fixture, header UI-теста и parity-файла | Без нарушений; предупреждения существующей конфигурации |
| `git diff --check` | Без ошибок |

Артефакты находятся вне репозитория, в `/private/tmp/features-MYO-7698.vZEZra/`:

- `WKReprosFinal.xcresult` и `wk-repros-final.log` — итоговый UI-прогон.
- `WKButtonHeaderSnapshotsFinal.xcresult` и `wk-button-header-snapshots-final.log` — итоговый запуск snapshot-, state-, parity- и replay-тестов.
- `wk-repros-original.log` — исходные дефекты: WK drag не прокручивал родителя, header callback переставал работать после второго возврата.
- `wk-glass-final.mp4` — видео; красное pressed-состояние видно около 27.4 s, shrink — около 38 s.
- `wk-glass-final-pressed.png` — кадр с pressed-color.
- `wk-glass-final-shrink-pressed-sampled.png` — кадр с pressed-color и shrink.

Фактическая команда UI-прогона из лога, из корня WrapKit:

```sh
DEVELOPER_DIR=/Users/sli/Downloads/Xcode.app/Contents/Developer xcodebuild test \
  -workspace Wrapkit.xcworkspace \
  -scheme WrapKitUITests \
  -destination 'platform=iOS Simulator,id=75DBAB34-4A2F-40D9-8C49-C0C4AD689113' \
  -derivedDataPath /private/tmp/features-MYO-7698.vZEZra/WK-UI-DD \
  -parallel-testing-enabled NO \
  -collect-test-diagnostics never \
  -only-testing:WrapKitUITests/GlassButtonScrollUITests/test_draggingFromGlassButtonScrollsWithoutActivatingIt_thenTapActivatesOnce \
  -only-testing:WrapKitUITests/HeaderAfterPopUITests/test_primaryHeaderActionWorksBeforeAndAfterUIKitPushPop \
  -resultBundlePath /private/tmp/features-MYO-7698.vZEZra/WKReprosFinal.xcresult
```

Для повторного запуска выбрать новые пути DerivedData/result bundle; существующий `.xcresult` не перезаписывать. Проект должен быть сгенерирован из текущего `WrapKitCore/Project.swift`.

## Snapshot- и contract-проверки

`WKButtonHeaderSnapshotsFinal.xcresult` / `wk-button-header-snapshots-final.log`: финальный запуск на том же iPhone 17 Pro / iOS 26.2 завершён успешно.

| Suite | Результат |
| --- | --- |
| `ButtonSnapshotTests` | 56/56 PASS |
| `NativeNavigationHeaderUpdateSnapshotTests` | 2/2 PASS |
| `NavigationBarUpdateSnapshotTests` | 17/17 PASS |
| `SUIButtonSnapshotTests` | 31/31 PASS |
| `SUIButtonStateModelTests` | 15/15 PASS |
| `SUINavigationBarParityTests`, включая два новых remount/replay теста | 21/21 PASS |
| `SwiftUIOutputReplayClosureStoreTests` | 12/12 PASS |
| Всего | 154/154 PASS, 0 ошибок |

Baseline-файлы не обновлялись: в `git status` нет изменений snapshot-изображений. Это проверка выбранных suites на одном runtime, не полный паритет всех компонентов и платформ.

## Дополнительная ручная проверка

1. Запустить host с `--glass-button-scroll=wrapKit`, затем с `--glass-button-scroll=wrapKitShrink`. Провести вверх от центра кнопки: список прокручивается, счётчик не меняется. Нажать и удержать кнопку: виден pressed-color, при shrink кнопка уменьшается; после отпускания стиль возвращается и action выполняется один раз.
2. Запустить host с `--header-after-pop`: нажать Search, пять раз открыть дочерний экран, вернуться и снова нажать Search. Счётчик должен последовательно дойти до 6.
3. Дополнительно проверить disabled/отсутствие action через Output во время удержания: pressed-состояние сбрасывается; повторное включение не оставляет кнопку красной/уменьшенной. Этот переход проверен по исходникам, но отдельного автоматического UI-сценария для него пока нет.

## Ограничения

- Изолированные UI-тесты не заменяют финальную проверку экранов NUR.Features с явно подключённым локальным WrapKit или опубликованной версией. Exact pin на remote WrapKit не использует соседний checkout.
- Этот прогон не подтверждает runtime-поведение macOS, Catalyst, tvOS, watchOS и старых iOS. UIKit bridge не добавлялся; прежний tvOS guard сохранён.
- Коммиты, публикация WrapKit и обновление consumer pins не выполнялись.
