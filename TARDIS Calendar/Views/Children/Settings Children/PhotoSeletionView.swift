//
//  PhotoSeletionView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 3/11/24.
//

import SwiftUI

struct PhotoSelectionView: View {
    
    @State var useDefaultNowIcon: Bool = false
    @Environment(\.dimensions) var dimensions
    @State var iconPhoto: Image = Image("face")
    
    var body: some View {
        
        VStack {
            
            Spacer()
            Text("Now Icon")
                .dynamicTypeSize(.xxxLarge)
                .fontWeight(.black)
            ZStack {
                Circle()
                    .frame(width: dimensions.mediumEvent, height: dimensions.mediumEvent).foregroundColor(.blue)
                    .zIndex(9)
                    .shadow(color: .white, radius: dimensions.mediumEvent * 0.1)
                NowView.nowIcon
                    .resizable()
                    .aspectRatio(contentMode:.fit)
                    .frame(width:dimensions.mediumEvent * 0.9, height: dimensions.mediumEvent * 0.9, alignment:.center)
                    .clipShape(Circle())
                    .zIndex(10)
            }
            Toggle("Use Default: ", isOn: $useDefaultNowIcon)
            Spacer()
            
            // TODO: - Here is where I need to learn more to make this photo thing happen. See project notes.
//            if !useDefaultNowIcon {
//                PhotosPicker("Choose a New Photo", selection: $iconPhoto, matching: .images)
//                    .onChange(of: iconPhoto) { _ in
                        // A PhotosPicker item cannot be persisted as a UserDefault (plist) item. I will need to use a different method here.
                        //                        if let photo = iconPhoto {
                        //                            UserDefaults.standard.set(Image(photo), forKey: "nowIcon")
                        //                        }
            Spacer()
            
        } // End of VStack
        .frame(maxWidth: dimensions.mediumEvent)
    }
        
} // End of photoSelectionView



