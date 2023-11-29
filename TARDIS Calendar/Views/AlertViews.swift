//
//  AlertViews.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/28/23.
//

import Foundation
import SwiftUI


struct AlertViews: View {
    
    var stateBools = StateBools.shared
    var screen: GeometryProxy
    
    var body: some View {
        
        ZStack {
            
            if stateBools.internetPersistentlyDown {
                
                Text("Check Internet Connection.")
                    .foregroundColor(.red)
                    .fontWeight(.bold)
                    .position(x: screen.size.width * 0.75, y: screen.size.height * 0.9)
                    .onTapGesture {stateBools.internetPersistentlyDownInfo = true}
                    .alert("Please let a helper know that your internet connection is unreliable. Your calendar may be missing information.", isPresented: $stateBools.internetPersistentlyDownInfo) {
                        Button("OK", role: .cancel, action: {})
                    }
            }
        }
        
    }
}
