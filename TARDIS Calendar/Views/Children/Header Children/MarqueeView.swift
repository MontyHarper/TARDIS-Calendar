//
//  MarqueeView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 12/11/23.
//

import EventKit
import Foundation
import SwiftUI

struct MarqueeView: View {

    var controller: MarqueeViewModel
    @Environment(\.dimensions) private var dimensions
    
    @State var isShowingPausedText = false
    
    var marqueeWidth: Double {
        min(dimensions.width * 0.85, controller.totalTextWidth * 1.1)
    }
    var isScrolling: Bool {
        controller.totalTextWidth > marqueeWidth
    }
    var pausedHeight: Double {
       Double( Int (controller.totalTextWidth / (marqueeWidth * 0.75)) + 1) * dimensions.lineHeight
    }
    
    var body: some View {
                    
        TimelineView(.periodic(from: Date.now, by: 0.01667)) {context in
            
            
            ZStack {
                
                VStack {
                    if isScrolling {
                        Text(controller.frame(context.date).text)
                            .offset(x: controller.frame(context.date).offset, y: 0.0)

                    } else {
                        Text(controller.nonScrollingText)
                    }
                }
                .padding()
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .frame(width: marqueeWidth, height: dimensions.lineHeight, alignment: .center)
                .background(Color(hue: 0.0, saturation: 0.0, brightness: 1.0, opacity: 0.5))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                .popover(isPresented: $isShowingPausedText) {
                    
                    VStack {
                        
                            ForEach(controller.banners, id: \.title) {banner in
                                HStack {
                                    Label("Until \(banner.endDate.formatted(date: .omitted, time: .shortened)) (\(banner.endDate.relativeTimeDescription))", systemImage: "clock")
                                    Spacer()
                                }
                                .padding(.top)
                                .foregroundColor(.blue)
                                HStack {
                                    Text(banner.title)
                                        .padding(.bottom)
                                        .padding(.leading)
                                    Spacer()
                                }
                            }
                        
                    }
                    .frame(width: marqueeWidth * 0.75)
                    .onLongPressGesture(minimumDuration: 0.05, maximumDistance: 20) {
                        isShowingPausedText.toggle()
                    }
                }
            }
            .font(Font(controller.marqueeFont))
            .foregroundColor(.primary)
            .onChange(of: isShowingPausedText) {value in
                controller.togglePause()
            }
        }
        .onLongPressGesture(minimumDuration: 0.05, maximumDistance: 20) {
            isShowingPausedText.toggle()
        }
        .task {
            print("New MarqueeView: ", Date().timeIntervalSince1970)
        }
    }
}


class MarqueeViewModel {
    
    let banners: [EKEvent]
    var scrollingText: String
    let nonScrollingText: String
    var characterWidths = [Double]()
    var timeMarkers = [TimeInterval]()
    var startTime = 0.0
    var runningTime = 0.0
    let speed = 60.0 // points/second
    let marqueeFont: UIFont // Using a UIFont because the width can be measured.
    var isPaused = false
    var pauseText = ""
    var pauseOffset = 0.0
    var pauseTime = 0.0
    var refreshDate: Date
    
    init(_ banners: [EKEvent], fontSize: Double, refreshDate: Date) {
        self.banners = banners
        print("making a new MarqueeViewModel")
        self.refreshDate = refreshDate
        scrollingText = ""
        for banner in banners {
            scrollingText = scrollingText + banner.title + " ★ "
        }
        nonScrollingText = scrollingText.isEmpty ? "" : " ★ " + scrollingText
        scrollingText = scrollingText + " REPEATING...  ★  "
        var text = scrollingText
        marqueeFont = UIFont.systemFont(ofSize: fontSize, weight: .black)
        for _ in 0..<scrollingText.count {
            let first = String(text.removeFirst())
            let width = first.size(withAttributes: [.font: marqueeFont]).width
            characterWidths.append(width)
            runningTime += width/speed
            timeMarkers.append(runningTime)
            text += first
        }
        startTime = Date().timeIntervalSince1970
        print("Made a new MarqueeViewModel: ", startTime)
    }

    var totalTextWidth: CGFloat {
        scrollingText.size(withAttributes: [.font: marqueeFont as Any]).width
    }

    
    // Given a time, return the text and offset that should be displayed at that moment.
    func frame(_ date: Date) -> (text: String, offset: Double) {
        
        if isPaused {
            return(text: pauseText, offset: pauseOffset)
        } else {
            let time = (date.timeIntervalSince1970 - startTime).truncatingRemainder(dividingBy: runningTime)
            let index = (timeMarkers.firstIndex(where: {time < $0}) ?? 0)
            let startStringIndex = scrollingText.startIndex
            let endStringIndex = scrollingText.endIndex
            let midStringIndex = scrollingText.index(scrollingText.startIndex, offsetBy: index)
            let text = String(scrollingText[midStringIndex..<endStringIndex]) + String(scrollingText[startStringIndex..<midStringIndex])
            let offset = characterWidths[index] * ((timeMarkers[index] - time)/(timeMarkers[index] - (index == 0 ? 0 : timeMarkers[index - 1])) - 1.0)
            pauseText = text
            pauseOffset = offset
            pauseTime = date.timeIntervalSince1970
            return(text: text, offset: offset)
        }
    }
    
    func togglePause() {
        isPaused.toggle()
        startTime = startTime + (Date().timeIntervalSince1970 - pauseTime)
    }
}



