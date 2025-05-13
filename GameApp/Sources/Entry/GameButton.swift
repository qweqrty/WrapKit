import SwiftUI

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
                            width: max(min(geometry.size.width * 0.3, 200), 150), // Минимум 150, максимум 200
                            height: max(min(geometry.size.width * 0.075, 50), 75) // Минимум 40, максимум 50
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
            .frame(height: max(min(geometry.size.width * 0.075, 75), 40))
        }
        .frame(minHeight: 40, maxHeight: 75) // Ограничиваем высоту
    }
}

