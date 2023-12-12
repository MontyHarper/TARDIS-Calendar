//
//  MarqueeView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 12/11/23.
//

import Foundation
import SwiftUI

struct MarqueeView: View {
    
    @State var message: String
    
    var body: some View {
        
        TimelineView(.periodic(from: .now, by: 0.2)) {timeline in
                messageView(message: $message, date: timeline.date)
        }
    }
}
    
struct messageView: View {
    
    @Binding var message: String
    var date: Date
    
    let messageFont = Font.system(size: 24).monospaced()
    
    var body: some View {
        
        ZStack {
            Color(.white)
                .frame(width: 600, height: 50)
            Text(message)
                .lineLimit(1)
                .font(messageFont)
                .fontWeight(.black)
                .foregroundColor(.primary)
                .background(.white)
                .frame(width: 550)
                .onChange(of: date) {date in
                    guard !message.isEmpty else {
                        return
                    }
                    let first = message.removeFirst()
                    message = message + String(first)
                }
        }
    }
}

