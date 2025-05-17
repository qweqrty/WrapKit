import SwiftUI

struct SettingsView: View {
    @Binding var musicEnabled: Bool
    @Binding var isPresented: Bool
    @Binding var soundEffectsEnabled: Bool
    @Binding var vibrationEnabled: Bool
    @Binding var selectedLanguage: String
    let styleConfig: SettingsStyleConfig
    
    @State private var showContent = false
    @State private var showBackground = false
    
    var body: some View {
        ZStack {
            
            Color.black
                .opacity(showBackground ? 0.5 : 0.0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: showBackground)
                .onTapGesture {
                    close()
                }
            
            if showContent {
                VStack(spacing: 8) {
                    Text("Settings")
                        .font(styleConfig.titleFont)
                        .foregroundColor(styleConfig.sectionHeaderColor)
                    
                    GameToggle(
                        isOn: $musicEnabled,
                        onImage: "soundOn",
                        offImage: "soundoff",
                        size: CGSize(width: 50, height: 50),
                        backgroundColor: Color.black.opacity(0.3),
                        borderColor: .yellow,
                        borderWidth: 2,
                        cornerRadius: 20,
                        title: "Music",
                        font: styleConfig.titleFont
                    )
                    
                    GameToggle(
                        isOn: $vibrationEnabled,
                        onImage: "soundOn",
                        offImage: "soundoff",
                        size: CGSize(width: 50, height: 50),
                        backgroundColor: Color.black.opacity(0.3),
                        borderColor: .yellow,
                        borderWidth: 2,
                        cornerRadius: 20,
                        title: "Vibration",
                        font: styleConfig.titleFont
                    )
                    
                    VStack {
                        GameButton(title: "Restore", backgroundImageName: "menuItem") {
                            print("Restore")
                        }
                        
                        
                        GameButton(title: "Close", backgroundImageName: "menuItem2") {
                            close()
                        }
                        .offset(y: -10)
                    }
                    .padding(.top, 15)
                }
                .padding()
                .background(Color.white.opacity(0.95))
                .cornerRadius(30)
                .shadow(radius: 20)
                .frame(maxWidth: 350)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            showBackground = true
            withAnimation(.spring()) {
                showContent = true
            }
        }
    }
    
    private func close() {
        withAnimation(.spring()) {
            showContent = false
        }
        
        showBackground = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}
