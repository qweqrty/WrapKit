// TODO TOGGLE
// TO DO LANGUAGE PICKER

import SwiftUI

struct SettingsView: View {
//    @Environment(\.dismiss) var dismiss
    @Binding var musicEnabled: Bool
    @Binding var soundEffectsEnabled: Bool
    @Binding var vibrationEnabled: Bool
    @Binding var selectedLanguage: String
    let styleConfig: SettingsStyleConfig
    
    
    var body: some View {
        ZStack {
            
            Image(styleConfig.backgroundImage)
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0)
                .edgesIgnoringSafeArea(.all)
            
            
            VStack(spacing: 20) {
                
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
                
              
                GameButton(title: "Restore", backgroundImageName: "menuItem") {
                    print("Restore")
                }
                
                GameButton(title: "Close", backgroundImageName: "menuItem2") {
//                    dismiss()
                }
            }
            .padding()
            
        }
    }
}

