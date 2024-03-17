//
//  HorizontalLayoutNoOverlap.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/17/23.
//
//  This Layout determines when two views overlap and removes overlapping views to off-screen.
//  Thus as the user zooms in, labels will get thinned out so they don't overlap and become unreadable.
//
//  *** The input array must be sorted in time for this view to work properly! ***
//

import Foundation
import SwiftUI

struct HorizontalLayoutNoOverlap: Layout {
        
    var minimumSpacing: CGFloat = 15
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let tallest = subviews.lazy.map {
            $0.sizeThatFits(.init(width: proposal.width, height: nil)).height
        }.max() ?? .zero
        return .init(width: proposal.width ?? .zero, height: tallest)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        
        
        // MARK: - Size/Locate each Subview
        // This creates a frame for each subview based on its size and location.

        let frames = subviews.enumerated().map { index, view in
            let size = view.sizeThatFits(.unspecified)
            let proportion = view[xPositionKey.self]
            return CGRect(origin:
                    .init(
                        x: bounds.origin.x + bounds.width * proportion,
                        y: bounds.origin.y + bounds.height * 0.5
                    )
                          , size: .zero
            )
            .insetBy(dx: -size.width / 2, dy: -size.height / 2)
        }
        

        // MARK: - Filter Subviews
        
        // Sorts the subviews into order from left to right.
        let sortedIndices = subviews.indices.sorted(by: {subviews[$0][xPositionKey.self] < subviews[$1][xPositionKey.self]})
        
        // BestFit will collect indexes of views that can be displayed.
        var bestFit = Set([0])
       
        // This loop determines which views can be displayed. First view is always a yes. Then the next view to the right that doesn't overlap, then the next, etc.
        var compareWithIndex = 0
        
        for index in 1..<sortedIndices.count {
            if frames[sortedIndices[compareWithIndex]].maxX + minimumSpacing < frames[sortedIndices[index]].minX {
                bestFit.insert(index)
                compareWithIndex = index
            }
        }
        
        
        // MARK: - Place Subviews

        // Views that cannot be displayed will be placed at "nowhere" - well off-screen.
        let nowhere = CGPoint(x: 1e12, y: 1e12)

        for i in sortedIndices {
            let frame = frames[i]
            let view = subviews[i]
            view.place(
                at: (bestFit.contains(i)) ? frame.origin : nowhere,
                anchor: .topLeading,
                proposal: .init(width: frame.size.width, height: frame.size.height)
            )
        }
    }
}

