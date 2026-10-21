| Действие | Файл | Причина |
| --- | --- | --- |
| Изменён | `WrapKitCore/Project.swift` | Зависимость test host от WrapKit, UI-test target и shared scheme `WrapKitUITests` |
| Изменён | `WrapKitCore/Sources/WrapKitUI/SwiftUI/Views/Base/SUIButton/SUIButton.swift` | Press/release без перехвата ScrollView drag; сброс pressed-state при disable, отсутствии action и исчезновении |
| Изменён | `WrapKitCore/Sources/WrapKitUI/SwiftUI/Views/Custom/View+NavigationHeader.swift` | Разрешение актуального callback при нажатии вместо захваченной модели |
| Изменён | `WrapKitCore/TestHost/App.swift` | Запуск header/glass fixtures через launch arguments; обычный test-host запуск сохранён |
| Создан | `WrapKitCore/TestHost/GlassButtonScrollFixture.swift` | Native и WrapKit glass-кнопки в ScrollView, режим `.shrink`, счётчик реальных action |
| Создан | `WrapKitCore/TestHost/HeaderAfterPopFixture.swift` | Изолированный UIKit push/pop с нативным SwiftUI header и обновляемым callback |
| Изменён | `WrapKitCore/Tests/WrapKitiOStests/SwiftUITests/SUINavigationBarParityTests.swift` | Две проверки remount/replay trailing callback |
| Создан | `WrapKitCore/UITests/GlassButtonScrollUITests.swift` | Один drag → tap → hold сценарий в трёх режимах, снимки экранов |
| Создан | `WrapKitCore/UITests/HeaderAfterPopUITests.swift` | Реальные нажатия header-кнопки до и после пяти переходов, снимки экранов |
| Перенесён и обновлён | `reports/MYO-7698/done.md` | Единый отчёт об исправлениях header и glass вместо `reports/MYO-7698-header-after-pop/done.md` |
| Перенесён и обновлён | `reports/MYO-7698/files-modified.md` | Полная таблица девяти изменённых/добавленных source/test-файлов и отчётов |
| Перенесён и обновлён | `reports/MYO-7698/how-to-check.md` | Фактические результаты, артефакты, повторные проверки и ограничения |

Старый каталог `reports/MYO-7698-header-after-pop` больше не содержит файлов. Baseline-изображения и dependency manifests/pins не изменялись.
