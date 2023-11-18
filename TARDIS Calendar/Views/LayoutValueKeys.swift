//
//  LayoutValueKeys.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 9/9/23.
//

import Foundation
import SwiftUI

// Keys used to pass values associated with each view into the custom layout.

struct xPositionKey: LayoutValueKey {
    static let defaultValue: CGFloat = 0.0
}

extension View {
    func xPosition(_ percent: CGFloat) -> some View {
        layoutValue(key: xPositionKey.self, value: percent)
    }
}
