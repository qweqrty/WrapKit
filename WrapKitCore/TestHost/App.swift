import SwiftUI

// Минимальный host app для снапшот-тестов: сам ничего не делает, нужен только чтобы
// тесты грузились в живой UIApplication с экраном — тогда drawHierarchy(afterScreenUpdates:)
// корректно рендерит iOS 26 cornerConfiguration (иначе hostless он даёт пустую картинку).
@main
struct WrapKitTestHostApp: App {
    var body: some Scene {
        WindowGroup { EmptyView() }
    }
}
