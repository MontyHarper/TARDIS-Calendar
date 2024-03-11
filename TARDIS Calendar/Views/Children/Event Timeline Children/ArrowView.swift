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
    
    @Environment(\.dimensions) private var dimensions
    
    var size: Double
    let arrowOffset = -7.75
    let arrow = UIImage(systemName: "arrow.right")
    var width: Double {
        Double(arrow?.size.width ?? .zero)
    }
    var height: Double {
        Double(arrow?.size.height ?? .zero)
    }
    var arrowSize: Double {
        dimensions.arrowSize
    }
    
    var body: some View {
        
        Circle()
            .foregroundColor(.clear)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: "arrow.right")
                    .resizable()
                    .frame(width: width * arrowSize, height: height * arrowSize)
                    .offset(x: -size * 0.5 - width * 0.45 * arrowSize)
                    .foregroundColor(.black)
                    .shadow(color: .white, radius: 20, x: 0)
            }
    }
}

