//
//  ContentView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 7/12/23.
//

import Foundation
import SwiftUI



struct ContentView: View {
    
    @State private var span: Double = Time.defaultSpan
    @State private var currentTime: Date = Date()
    @State private var animateSpan = false
    @State private var inactivityTimer: Timer?
    
    
    let updateTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    let spanTimer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        
        GeometryReader { screen in
            
            ZStack {
                
                LinearGradient(gradient: Gradient(stops: screenStops(span: span, now: currentTime)), startPoint: .leading, endPoint: .trailing).ignoresSafeArea()
                    
                    .gesture(DragGesture().onChanged { gesture in
                        let change = (gesture.translation.width / screen.size.width) * span * 0.05
                        let newSpan = span - change
                        if newSpan > Time.minSpan && newSpan < Time.maxSpan {
                            span = newSpan
                            animateSpan = false
                            inactivityTimer?.invalidate()
                        }
                    } .onEnded { _ in
                        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false, block: {_ in animateSpan = true})
                    })
                
                
                NowView(time: currentTime).position(x: 0.2 * screen.size.width, y: 0.5 * screen.size.height).foregroundColor(.gray)
                
                ForEach(dateLabelArray(span: span, now: currentTime), id: \.self.xLocation) {label in
                    
                    label.position(x: label.xLocation * screen.size.width, y: 0.1 * screen.size.height)
                    
                }
            }
            .onReceive(updateTimer) { time in
                currentTime = time
            }
            .onReceive(spanTimer) { time in
                span = spanCalc(span)
            }
            
        }.ignoresSafeArea()
        
    }
    
   
    func spanCalc(_ span: Double) -> Double {
        
        
        if animateSpan {
            
            if abs(Time.defaultSpan - span) > 0.01 {
                var base = 1.0
                if span < Time.defaultSpan {
                    base = 0.99
                } else {
                    base = 0.95
                }
                let newSpan = Time.defaultSpan + base * (span - Time.defaultSpan)
                print(newSpan)
                return newSpan
                
            } else {
                animateSpan = false
                return span
            }
            
        } else {
            return span
        }
    }
         

    struct NowView: View {
        
        var time: Date
        
        var body: some View {
          
                    VStack {
                        Text(" ")
                        ZStack {
                            Circle().frame(width: 75, height: 75).foregroundColor(.yellow).shadow(color: .white, radius: 20)
                            Settings.userImage.resizable().aspectRatio(contentMode:.fit).frame(width:70, height:70, alignment:.center).clipShape(Circle())
                        }
                        Text(time, format: .dateTime.hour().minute())
                            .fontWeight(.bold)
                        Text(" ")
                    
                
            }
        }
    }
}
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }



