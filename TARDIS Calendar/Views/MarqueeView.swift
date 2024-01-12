//
//  MarqueeView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 12/11/23.
//

import Foundation
import SwiftUI

struct MarqueeView: View {

    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var size: Dimensions

    var body: some View {
        
        if let controller = eventManager.marquee {
            TimelineView(.animation) {context in
                Text(controller.frame(context.date).text)
                    .padding()
                    .lineLimit(1)
                    .font(Font(controller.marqueeFont))
                    .foregroundColor(.primary)
                    .offset(x: controller.frame(context.date).offset, y: 0.0)
                    .fixedSize(horizontal: true, vertical: false)
                    .onLongPressGesture(minimumDuration: 0.05, maximumDistance: 20.0) {
                        controller.togglePause()
                    }
            }
        } else {
            Text("There is nothing to display yet...")
        }
    }
}


class MarqueeController {
    
    let message: String
    let refreshDate: Date
    var characterWidths = [Double]()
    var timeMarkers = [TimeInterval]()
    var startTime = 0.0
    var runningTime = 0.0
    let speed = 60.0 // points/second
    let marqueeFont: UIFont // Using a UIFont because the width can be measured.
    var pause = false
    var pauseText = ""
    var pauseOffset = 0.0
    var pauseTime = 0.0
    
    init(_ inputText: String, refresh: Date, fontSize: Double) {
        print("making a new controller: ", inputText)
        // Trying this - adding an "end of message" so Mom won't keep reading it over and over. Don't know if that will help or not.
        self.message = (inputText == "") ? "No Text Available" : inputText + " END OF MESSAGE  ★  "
        self.refreshDate = refresh
        var text = message
        marqueeFont = UIFont.systemFont(ofSize: fontSize, weight: .black)
        for _ in 0..<message.count {
            let first = String(text.removeFirst())
            let width = first.size(withAttributes: [.font: marqueeFont]).width
            characterWidths.append(width)
            runningTime += width/speed
            timeMarkers.append(runningTime)
            text += first
        }
        startTime = Date().timeIntervalSince1970
    }
    
    // Given a time, return the text and offset that should be displayed at that moment.
    func frame(_ date: Date) -> (text: String, offset: Double) {
        
        if pause {
            return(text: pauseText, offset: pauseOffset)
        } else {
            let time = (date.timeIntervalSince1970 - startTime).truncatingRemainder(dividingBy: runningTime)
            let index = (timeMarkers.firstIndex(where: {time < $0}) ?? 0)
            let startStringIndex = message.startIndex
            let endStringIndex = message.endIndex
            let midStringIndex = message.index(message.startIndex, offsetBy: index)
            let text = String(message[midStringIndex..<endStringIndex]) + String(message[startStringIndex..<midStringIndex])
            let offset = characterWidths[index] * ((timeMarkers[index] - time)/(timeMarkers[index] - (index == 0 ? 0 : timeMarkers[index - 1])) - 1.0)
            pauseText = text
            pauseOffset = offset
            pauseTime = date.timeIntervalSince1970
            return(text: text, offset: offset)
        }
    }
    
    func togglePause() {
        pause.toggle()
        startTime = startTime + (Date().timeIntervalSince1970 - pauseTime)
    }
}



