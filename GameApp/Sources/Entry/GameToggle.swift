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
    
    var body: some View {
        HStack {
            Text(title)
                .font(font)
            Spacer()
            Button(action: {
                withAnimation(animation) {
                    isOn.toggle()
                }
            }) {
                
                Image(isOn ? onImage : offImage)
                    .resizable()
                    .frame(width: size.width, height: size.height)
                    .scaledToFit()
                
//                ZStack {
//                    RoundedRectangle(cornerRadius: cornerRadius)
//                        .fill(backgroundColor)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: cornerRadius)
//                                .stroke(borderColor, lineWidth: borderWidth)
//                        )
//                        .frame(width: size.width, height: size.height)
//                    
//                    (isOn ? onImage : offImage)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: size.height * 0.6, height: size.height * 0.6)
//                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        }
}

//ZStack {
//    RoundedRectangle(cornerRadius: cornerRadius)
//        .fill(backgroundColor)
//        .overlay(
//            RoundedRectangle(cornerRadius: cornerRadius)
//                .stroke(borderColor, lineWidth: borderWidth)
//        )
//        .frame(width: size.width, height: size.height)
//    
//    (isOn ? onImage : offImage)
//        .resizable()
//        .scaledToFit()
//        .frame(width: size.height * 0.6, height: size.height * 0.6)
//}
