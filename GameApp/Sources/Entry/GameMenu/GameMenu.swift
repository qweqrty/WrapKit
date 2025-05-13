import SwiftUI
import Lottie

// Модуль основного меню
struct GameMenu: View {
    let title: String
    let buttons: [MenuButtonConfig]
    let backgroundImageName: String
    let backgroundAnimation: String
    
    var body: some View {
        ZStack {
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.3))
            
            LottieView(animation: .named(backgroundAnimation))
              .looping()
              .resizable()
              .ignoresSafeArea()
//              .scaledToFill()
//              .edgesIgnoringSafeArea(.all)

            VStack(spacing: 40) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                Spacer(minLength: 100)
                
                ForEach(buttons) { button in
                    GameButton(
                        title: button.title,
                        backgroundImageName: button.backgroundImageName,
                        action: button.action
                    )
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal)
        }
    }
}

// Конфигурация кнопки меню
struct MenuButtonConfig: Identifiable {
    let id = UUID() // Автоматический уникальный идентификатор для ForEach
    let title: String
    let backgroundImageName: String
    let action: () -> Void // Действие для кнопки
}
