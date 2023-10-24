//
//  Events.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 8/2/23.
//

import Foundation
import SwiftUI
import EventKit



struct EventView: View {
    
    @State var isSelected = false {
        didSet {
        }
    }
    
    var event: EKEvent
    
    init (event: EKEvent) {
        self.event = event
    }
    
    var size: Double = 25.0
    
    var timeToEvent: TimeInterval {
        event.startDate.timeIntervalSince1970 - Date().timeIntervalSince1970
    }
    
    var body: some View {
        
        if isSelected {
            
            ZStack {
                Circle()
                    .fill(.yellow)
                    .frame(width: size*3, height: size*3)
                VStack {
                    Text(event.title)
                    Text("\(timeToEvent.formatted())")
                }
            }
            .onTapGesture {
                isSelected.toggle()
            }
            
        } else {
            
            Circle()
                .fill(.yellow)
                .frame(width: size, height: size)
                .overlay(
                    Text(event.title).fixedSize().offset(y: -size), alignment: .bottom)
                .overlay(
                    Image(systemName: "arrow.right")
                        .offset(x: -size*0.61),
                    alignment: .init(horizontal: .center, vertical: .center))
                .overlay(
                    Text(event.startDate.formatted()).fixedSize().offset(y: size), alignment: .bottom)
                .onTapGesture {
                    isSelected.toggle()
                }
        }
    } // End of body
 
}

