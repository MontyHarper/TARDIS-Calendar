//
//  Events.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 8/2/23.
//

import Foundation
import SwiftUI
import EventKit

// probably don't need
enum EventViewMode {
    case minimized
    case normal
    case expanded
    
    // We can refer to defaultMode in the code and only need to change it here
    static let defaultMode = EventViewMode.minimized
}

struct EventView: View {
    
    var event: Event
    @Binding var isExpanded: Bool
    
    var size: Double = 30.0
    var arrowOffset: Double = -6.0
    
    var timeToEvent: TimeInterval {
        event.startDate.timeIntervalSince1970 - Date().timeIntervalSince1970
    }
    
    var body: some View {
        
        if !isExpanded {
            
            Circle()
                .fill(.yellow)
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: "arrow.right")
                        .offset(x: -size*0.5 + arrowOffset),
                    alignment: .init(horizontal: .center, vertical: .center))
                .onTapGesture {
                    isExpanded = true
                }
        } else {
            
            
            ZStack {
                Circle()
                    .fill(.yellow)
                    .frame(width: size*3, height: size*3)
                    .overlay(
                        Image(systemName: "arrow.right")
                            .offset(x: -size*3*0.5 + arrowOffset),
                        alignment: .init(horizontal: .center, vertical: .center))
                VStack {
                    Text(event.title)
                    Text(timerInterval: Date()...event.startDate)
                }
            }
            .onTapGesture {
                isExpanded = false
            }
            
            
        }
    } // End of body
    
}

