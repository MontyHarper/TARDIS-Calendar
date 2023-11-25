//
//  NowView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/13/23.
//
//  This is the NOW Icon on the timeline.
//  Initially I gave it a detail view, but decided that was not needed.
//

import Foundation
import SwiftUI

struct NowView: View {
        
    var body: some View {
        
        // TODO: - this is hard-wired for now. Will need to allow user to specify an image and retrieve it here from user defaults.
        
        let image = Settings.shared.userImage
        
        Group {
                
            ArrowView(size: 100.0)
                .zIndex(-90)
            Circle().frame(width: 100, height: 100).foregroundColor(.yellow).shadow(color: .white, radius: 20)
            image.resizable().aspectRatio(contentMode:.fit).frame(width:90, height:90, alignment:.center).clipShape(Circle())
                
            }
        
    }
}





