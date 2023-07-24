//
//  ContentView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 7/12/23.
//

import Foundation
import SwiftUI



struct ContentView: View {
    
    @State private var trailingDate: Double = Days.initialTrailingDate

    var minTrailingDate: Double {
        Days.calendar.date(byAdding: .hour, value: 1, to: Date())!.timeIntervalSince1970
    }
    var maxTrailingDate: Double {
        Days.calendar.date(byAdding: .day, value: Settings.maxTimeInDays, to: Date())!.timeIntervalSince1970
    }
    
    var body: some View {
        
        
        GeometryReader { screen in
            
        ZStack {
            
            LinearGradient(gradient: Gradient(stops: screenStops(trailingDate: trailingDate)), startPoint: .leading, endPoint: .trailing).ignoresSafeArea()
             
            Slider(value: $trailingDate, in: minTrailingDate...maxTrailingDate).position(x:0.5 * screen.size.width, y: 0.8 * screen.size.height)
            
            NowView().position(x: 0.2 * screen.size.width, y: 0.5 * screen.size.height)
            
            ForEach(dateLabelArray(trailingDate), id: \.self.xLocation) {label in
                
                label.position(x: label.xLocation * screen.size.width, y: 0.1 * screen.size.height)
                
            }
        }
    }.ignoresSafeArea()
}

    struct NowView: View {
        var body: some View {
            ZStack {
                Circle().frame(width: 75, height: 75).foregroundColor(.yellow).shadow(color: .white, radius: 20)
                Text("Now")
            }
        }
    }
}
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }



