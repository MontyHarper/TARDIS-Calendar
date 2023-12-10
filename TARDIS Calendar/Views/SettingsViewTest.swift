//
//  SettingsViewTest.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/19/23.
//
//  Using this to test the structure of the view using preview.
//  This view is just for me to learn from.
//  You should delete this view once the SettingsView is working well.
//

import Foundation
import SwiftUI
import EventKit

struct SettingsViewTest: View {
    
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        NavigationView {
            VStack {
                
                NavigationLink("Choose Calendars", destination:
                                Text("choose calendars page")
                    .navigationTitle("Choose Calendars")
                )
                .font(.title)
                
                NavigationLink("Change Now Icon", destination: Text("photo picker goes here")
                    .navigationTitle("Choose an Image"))
                .font(.title)
                
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}





struct Previews_SettingsViewTest_Previews: PreviewProvider {
    static var previews: some View {
        
        SettingsViewTest()
            .previewInterfaceOrientation(.landscapeRight)
    }
}

