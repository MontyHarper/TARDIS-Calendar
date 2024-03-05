//
//  BackgroundView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/13/23.
//
//  Background View is a color gradient with many stops, representing day, night, sunrise, and sunset.
//

import SwiftUI

struct BackgroundView: View {
    
    var stops: [Gradient.Stop]
    
    var body: some View {
        
        LinearGradient(gradient: Gradient(stops: stops), startPoint: .leading, endPoint: .trailing)
            .ignoresSafeArea()
    }
}
