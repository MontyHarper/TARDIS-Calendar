//
//  HiddenButton.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 3/8/24.
//

import SwiftUI

struct HiddenSettingsButton: View {
    
    @State var settingsIsVisible = false
    @State var settingsAlertIsVisible = false
    
    var body: some View {
        
        Color(.clear)
            .frame(width: 80, height: 80)
            .contentShape(Rectangle())
            .onTapGesture(count: 3, perform: {
                settingsAlertIsVisible = true
            })
            .alert("Do you want to change the settings?", isPresented: $settingsAlertIsVisible) {
                Button("No - Touch Here to Go Back", role: .cancel, action: {})
                Button("Yes", action: {settingsIsVisible = true})
            }
            .sheet(isPresented: $settingsIsVisible) {
                SettingsView()
            }
        
    }
}
