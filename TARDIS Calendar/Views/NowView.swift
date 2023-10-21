//
//  NowView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/13/23.
//

import Foundation
import SwiftUI

struct NowView: View {
    
    @State private var detailView = false
    
    var body: some View {
        
        ZStack {
            
            if detailView {
                
                Circle()
                    .frame(width: 250, height: 250)
                    .foregroundColor(.yellow)
                    .shadow(color: .white, radius: 20)
                    .opacity(0.70)
                    .overlay(
                        VStack {
                            Text("Next activity: working on this")
                            
                        }
                    )
                    .clipShape(ContainerRelativeShape()).padding()
                
            } else {
                
                Circle().frame(width: 100, height: 100).foregroundColor(.yellow).shadow(color: .white, radius: 20)
                Settings.shared.userImage.resizable().aspectRatio(contentMode:.fit).frame(width:90, height:90, alignment:.center).clipShape(Circle())
                
            }
        }
        .onTapGesture(perform: {detailView.toggle()})
        
    }
}





