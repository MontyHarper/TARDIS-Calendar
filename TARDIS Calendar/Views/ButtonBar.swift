//
//  NextButtons.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 12/23/23.
//

import Foundation
import SwiftUI




// MARK: Button View
struct ButtonView: View {
    
    var size: Dimensions
    var button: ButtonModel
    @EnvironmentObject var eventManager: EventManager

    @State var rotateAmount: Double = 0.0
    
    var body: some View {
        
        ZStack {
            Circle()
                .foregroundColor(.yellow)
                .frame(width: size.tinyEvent, height: size.smallEvent)
            button.image
                .resizable()
                .foregroundColor(button.color)
                .frame(width: size.tinyEvent * 0.95, height: size.tinyEvent * 0.95, alignment: .center)
                
        } // End of ZStack
        .rotation3DEffect(.degrees(rotateAmount), axis: (x: 0.5, y: 0.5, z: 0))
        .overlay {
            Text(button.bottomText)
                .font(.system(size: size.fontSizeSmall, weight: .bold))
                .offset(y: 0.65 * size.tinyEvent)
                .lineLimit(1)
        }
        .foregroundColor(.blue)
        .onLongPressGesture(minimumDuration: 0.05, maximumDistance: 20.0) {
            withAnimation(.linear(duration: 0.75)) {
                rotateAmount += 360
            }
            eventManager.buttonAction(type: button.id)
        }
    }
}


// MARK: Button Bar
struct ButtonBar: View {
    
    @EnvironmentObject var size: Dimensions
    @EnvironmentObject var eventManager: EventManager
    
    var body: some View {
        
        HStack {
            
            Spacer()
            
            ZStack {
                Color(.clear)
                    .frame(width: size.tinyEvent * Double(eventManager.buttonMaker.buttons.count) * 1.20, height: size.tinyEvent * 1.4)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                HStack {
                    
                    ForEach(eventManager.buttonMaker.buttons) {button in
                        ButtonView(size: size, button: button)
                    }
                    .offset(y: -0.1 * size.tinyEvent)
                }
                
            }
            .padding(EdgeInsets(top: 2, leading: 2, bottom: 5, trailing: 2))
            
            // spacer to keep button bar from abutting trailing edge
            Color(.clear)
                .frame(width: size.width * 0.05, height: 20.0)
        }
    }
}

