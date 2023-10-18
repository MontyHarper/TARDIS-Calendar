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
    
    @State private var isSelected = false
    
    var startDate: Date
    var endDate: Date
    var title: String
    
    var size: Double = 25.0
    var xLocation: Double = 0.0
    
    init(startDate: Date, endDate: Date, title: String) {
        self.startDate = startDate
        self.endDate = endDate
        self.title = title
    }
    
    var timeToEvent: TimeInterval {
        startDate.timeIntervalSince1970 - Date().timeIntervalSince1970
    }
    
    var body: some View {
        
        if isSelected {
            
            ZStack {
                Circle()
                    .fill(.yellow)
                    .frame(width: size*3, height: size*3)
                VStack {
                    Text(title)
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
                    Text(title).fixedSize().offset(y: -size), alignment: .bottom)
                .overlay(
                    Image(systemName: "arrow.right")
                        .offset(x: -size*0.61),
                    alignment: .init(horizontal: .center, vertical: .center))
                .onTapGesture {
                    isSelected.toggle()
                }
        }
    }
}

