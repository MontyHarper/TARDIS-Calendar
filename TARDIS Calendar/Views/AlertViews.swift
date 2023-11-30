//
//  AlertViews.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/28/23.
//

import Foundation
import SwiftUI


struct AlertViews: View {
    
    @StateObject var stateBools = StateBools.shared
    var screen: GeometryProxy
    var formatter = RelativeDateTimeFormatter()
    let dateWentDown = UserDefaults.standard.object(forKey: "lastTimeInternetWentDown") as? Date ?? Date()
    
    var body: some View {
                
        ZStack {
            
            if stateBools.internetIsDown {
                
                Text("Check Internet Connection.")
                    .foregroundColor(.red)
                    .fontWeight(.bold)
                    .position(x: screen.size.width * 0.75, y: screen.size.height * 0.9)
                    .onTapGesture {stateBools.internetIsDownInfo = true}
                    .alert("Your internet connection has been down since: \n\n\(formatter.localizedString(for: dateWentDown, relativeTo: Date()))\n\nYour calendar may be missing information. \n\nPlease let a helper know.", isPresented: $stateBools.internetIsDownInfo) {
                        Button("OK", role: .cancel, action: {})
                    }
            }
        }
        .onAppear {
            formatter.unitsStyle = .spellOut
            formatter.dateTimeStyle = .named
        }
        
    }
}
