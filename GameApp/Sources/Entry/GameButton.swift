import SwiftUI

// Модуль кнопки
struct GameButton: View {
    let title: String
    let backgroundImageName: String
    let action: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: action) {
                ZStack {
                    Image(backgroundImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: min(geometry.size.width * 0.3, 300), // 30% ширины или максимум 200
                            height: min(geometry.size.width * 0.075, 70) // 7.5% от ширины или максимум 50
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Text(title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.horizontal, 10)
                }
                .frame(maxWidth: .infinity)
                .shadow(radius: 5)
            }
            .frame(height: min(geometry.size.width * 0.075, 50))
        }
        .frame(height: 50) // Минимальная высота
    }
}

