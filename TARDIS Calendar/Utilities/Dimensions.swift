//
//  Dimensions.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 12/20/23.
//

import Foundation
import SwiftUI


struct Dimensions: EnvironmentKey {
        
    static var defaultValue: Self = Dimensions(.zero)
    
    var size: CGSize
    
    init(_ size: CGSize) {
        self.size = size
    }
        
    var width: Double {
        Double(size.width)
    }
    var height: Double {
        Double(size.height)
    }
    var fontSizeLarge: Double {
        height / 20.0
    }
    var fontSizeMedium: Double {
        height / 30.0
    }
    var fontSizeSmall: Double {
        height / 40.0
    }
    var lineHeight: Double {
        height / 22.0
    }
    var largeEvent: Double {
        height * 0.5
    }
    var mediumEvent: Double {
        height * 0.20
    }
    var smallEvent: Double {
        height * 0.15
    }
    var tinyEvent: Double {
        height * 0.11
    }
    var arrowSize: Double {
        height * 0.003
    }
    var timelineThickness: Double {
        height * 0.008
    }
    var buttonWidth: Double {
        tinyEvent * 1.2
    }
}

extension EnvironmentValues {
    var dimensions: Dimensions {
        get { self[Dimensions.self] }
        set { self[Dimensions.self] = newValue }
    }
}

extension View {
    func insertDimensionsIntoEnvironment(_ size: CGSize) -> some View {
        environment(\.dimensions, Dimensions(size))
    }
}
