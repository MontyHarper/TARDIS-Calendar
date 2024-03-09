//
//  HiddenButton.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 3/8/24.
//

import SwiftUI

struct HiddenSettingsButton: View {
    
    @EnvironmentObject var dimensions: Dimensions
    @State var stateBools = StateBools.shared
    @State var showSettingsAlert = false
    
    var body: some View {
        
        Color(.clear)
            .frame(width: 80, height: 80)
            .offset(x: dimensions.width - 40, y: 40)
            .contentShape(Rectangle())
            .onTapGesture(count: 3, perform: {
                showSettingsAlert = true
            })
            .alert("Do you want to change the settings?", isPresented: $showSettingsAlert) {
                Button("No - Touch Here to Go Back", role: .cancel, action: {})
                Button("Yes", action: {stateBools.showSettings = true})
            }
            .sheet(isPresented: $stateBools.showSettings) {
                SettingsView()
            }
        
    }
}
