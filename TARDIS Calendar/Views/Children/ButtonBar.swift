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
    
    @Environment(\.dimensions) private var dimensions
    var button: ButtonModel
    @EnvironmentObject var eventManager: EventManager

    @State var rotateAmount: Double = 0.0
    
    var body: some View {
        
        ZStack {
            Circle()
                .foregroundColor(.yellow)
                .frame(width: dimensions.tinyEvent, height: dimensions.smallEvent)
            button.image
                .resizable()
                .foregroundColor(button.color)
                .frame(width: dimensions.tinyEvent * 0.95, height: dimensions.tinyEvent * 0.95, alignment: .center)
                
        } // End of ZStack
        .rotation3DEffect(.degrees(rotateAmount), axis: (x: 0.5, y: 0.5, z: 0))
        .overlay {
            Text(button.bottomText)
                .font(.system(size: dimensions.fontSizeSmall, weight: .bold))
                .offset(y: 0.65 * dimensions.tinyEvent)
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
    
    @Environment(\.dimensions) private var dimensions
    @EnvironmentObject var eventManager: EventManager
    
    var body: some View {
        
        ZStack {
            Color(.clear)
                .frame(width: dimensions.buttonWidth * Double(eventManager.buttonMaker.buttons.count), height: dimensions.tinyEvent * 1.4)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            HStack {
                
                ForEach(eventManager.buttonMaker.buttons) {button in
                    ButtonView(button: button)
                }
                .offset(y: -0.1 * dimensions.tinyEvent)
            }
        }
        .padding(EdgeInsets(top: 2, leading: 2, bottom: 5, trailing: 2))
        
    }
}

