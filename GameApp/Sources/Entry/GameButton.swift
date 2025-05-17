import SwiftUI

struct GameButton: View {
    let title: String
    let backgroundImageName: String
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var offsetY: CGFloat = 0 // Смещение по Y для анимации
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                action()
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }) {
                ZStack {
                    Image(backgroundImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: max(min(geometry.size.width * 0.3, 200), 150),
                            height: max(min(geometry.size.width * 0.075, 50), 75)
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
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .offset(y: offsetY)
            }
            .frame(height: max(min(geometry.size.width * 0.075, 75), 40))
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = false
                        }
                    }
            )
            .buttonStyle(CustomButtonStyle())
            .onAppear {
                let randomDelay = Double.random(in: 0...0.5)
                DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
                    withAnimation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                    ) {
                        offsetY = -10
                    }
                }
            }
        }
        .frame(minHeight: 40, maxHeight: 75)
    }
}


struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(1.0)
    }
}
