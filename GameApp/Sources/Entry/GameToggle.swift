//
//  GameToggle.swift
//  GameMenu
//
//  Created by sunflow on 12/5/25.
//

import SwiftUI

struct GameToggle: View {
    @Binding var isOn: Bool
    
    var onImage: String
    var offImage: String
    var size: CGSize = CGSize(width: 60, height: 30)
    var backgroundColor: Color = .clear
    var borderColor: Color = .white
    var borderWidth: CGFloat = 2
    var cornerRadius: CGFloat = 15
    var animation: Animation = .easeInOut(duration: 0.2)
    var title: String
    var font: Font
    var action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(font)
            Spacer()
            Button(action: {
                action()
                withAnimation(animation) {
                    isOn.toggle()
                }
            }) {
                
                Image(isOn ? onImage : offImage)
                    .resizable()
                    .frame(width: size.width, height: size.height)
                    .scaledToFit()
            }
            .buttonStyle(OpacityButtonStyle())
        }
        }
}

struct OpacityButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(1.0)    }
}


