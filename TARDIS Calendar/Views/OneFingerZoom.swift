//
//  OneFingerZoom.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 3/8/24.
//

import SwiftUI

struct OneFingerZoom: ViewModifier {
    
    var width: Double
    var timeManager: TimeManager
    
    // minLoc limits the gesture to the future side of now, far enough from now that it doesn't cause the zoom to jump wildly.
    let minLoc = TimelineSettings.shared.nowLocation + 0.1
    
    @State private var dragStart: Double = 0.0
    
    let oneFingerZoom = DragGesture()
        
    
    func body(content: Content) -> some View {
        content
            .gesture(oneFingerZoom
            .onChanged { gesture in
                
                // If this is a new drag starting, save the location.
                if dragStart == 0.0 {
                    dragStart = gesture.startLocation.x
                    StateBools.shared.animateSpan = false
                }
                
                print("Drag Start: \(dragStart), Drag End: \(gesture.location.x)")
                
                // Divide by width to convert to unit space.
                let start = dragStart / width
                let end = gesture.location.x / width
                            
                guard (end > minLoc) && (start > minLoc) else {
                    return
                }
                
                // Save the location of this drag for the next event.
                dragStart = gesture.location.x
                
                // This call changes the trailing time in our timeline, if we haven't gone beyond the boundaries.
                timeManager.newTrailingTime(start: start, end: end)
                
            } .onEnded { _ in
                // When the drag ends, reset the starting value to zero to indicate no drag is happening at the moment.
                self.dragStart = 0.0
            })
    }
}


extension View {
    func oneFingerZoom(width: Double, timeManager: TimeManager) -> some View {
        modifier(OneFingerZoom(width: width, timeManager: timeManager))
    }
}
