//
//  Dimensions.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 12/20/23.
//

import Foundation
import SwiftUI


class Dimensions: ObservableObject {
        
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
        height * 0.25
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
    
    
}
