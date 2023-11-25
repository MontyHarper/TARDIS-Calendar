//
//  ArrowView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/16/23.
//
//  This view adds an arrow to the left of a view.
//  I made a separate file for it because it gets used both for EventView and NowView.
//

import Foundation
import SwiftUI

struct ArrowView: View {
    
    var size: Double
    let arrowOffset = -7.75
    
    var body: some View {
        
        Circle()
            .foregroundColor(.clear)
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: "arrow.right")
                    .offset(x: -size * 0.5 + arrowOffset)
                    .foregroundColor(.black)
                    .shadow(color: .white, radius: 3),
                alignment: .init(horizontal: .center, vertical: .center))
    }
}

