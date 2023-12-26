//
//  LayoutValueKeys.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 9/9/23.
//
//  Used in conjunction with HorizontalLayoutNoOverlap
//

import Foundation
import SwiftUI

// This key passes the xPosition of each view into the Layout for use in calculations.

struct xPositionKey: LayoutValueKey {
    static let defaultValue: CGFloat = 0.0
}

struct yPositionKey: LayoutValueKey {
    static let defaultValue: CGFloat = 0.0
}

extension View {
    func xPosition(_ percent: CGFloat) -> some View {
        layoutValue(key: xPositionKey.self, value: percent)
    }
    func yPosition(_ percent: CGFloat) -> some View {
        layoutValue(key: yPositionKey.self, value: percent)
    }
}

struct LayoutSizeKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}


