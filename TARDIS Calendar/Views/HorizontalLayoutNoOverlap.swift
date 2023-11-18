//
//  HorizontalLayoutNoOverlap.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/17/23.
//

import Foundation
import SwiftUI

struct HorizontalLayoutNoOverlap: Layout {
        
    var minimumSpacing: CGFloat = 20
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let tallest = subviews.lazy.map {
            $0.sizeThatFits(.init(width: proposal.width, height: nil)).height
        }.max() ?? .zero
        return .init(width: proposal.width ?? .zero, height: tallest)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        print("placeSubviews in NewHL2 Layout called.")
        
        
        // MARK: - Size/Locate each Subview
        // This creates a frame for each subview based on its size and location.
        // Even when I request .infinity, I am getting widths that do not accomodate the text in each subview.
        let frames = subviews.enumerated().map { index, view in
            let size = view.sizeThatFits(.unspecified)
            let proportion = view[xPositionKey.self]
            print("this view proxy has xPosition value: \(view[xPositionKey.self])")
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
        // Tested this line; it properly sorts the subviews into order from left to right.
        let sortedIndices = subviews.indices.sorted(by: {subviews[$0][xPositionKey.self] < subviews[$1][xPositionKey.self]})
        
        // BestFit will collect indexes of views that can display their labels.

       
        // Nested loop determines which views can display labels. First view is always a yes. Then the next view to the right that doesn't overlap, then the next, etc.
    
        var bestFit = Set([0])
        var index = 0
        let last = sortedIndices.count - 1
        if last > 0 {
            
        outerLoop: while index < last {
            
        innerLoop: for rightIndex in index+1...last {
            if frames[sortedIndices[index]].maxX + minimumSpacing < frames[sortedIndices[rightIndex]].minX {
                bestFit.insert(rightIndex)
                index = rightIndex
                break innerLoop
            }
            if rightIndex == last {
                break outerLoop
            }
        }
        }
        }
        print("best fit indexes: \(bestFit)")
        
        // My first thought was here I could call a function that would demote the views that don't fit, but I am not allowed to change an observed object from inside a view/layout. I can only place the subviews, not change them.

        
        // MARK: - Place Subviews


        let nowhere = CGPoint(x: 1e12, y: 1e12)

        for i in sortedIndices {
            let frame = frames[i]
            let view = subviews[i]
            view.place(
                
                // Each view is placed on screen if either its label fits (member of bestFit), or its mode is "demoted".
                // The ContentView calls this layout in two layers. In the first layer all views are in .normal mode, so we place bestFit views onscreen and others off; in the second layer all views are in .demoted mode, so they should all be placed onscreen, without labels.
                // The two layers ought to line up but they don't.
                at: (bestFit.contains(i)) ? frame.origin : nowhere,
                anchor: .topLeading,
                proposal: .init(width: frame.size.width, height: frame.size.height)
            )
        }
    }
}

