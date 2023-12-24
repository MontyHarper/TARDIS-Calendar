//
//  HeaderView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 12/19/23.
//

import SwiftUI

struct HeaderView: View {
    
    var size: Dimensions
    @StateObject var eventManager: EventManager
    
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMMM d, yyyy"
        return formatter.string(from: Date())
    }
    var dateFont: UIFont {
        UIFont.systemFont(ofSize: size.fontSizeMedium, weight: .black)
    }
    var dateWidth: Double {
        dateText.size(withAttributes: [.font: dateFont]).width
    }
    
    var body: some View {
        
        VStack {
            
            // Row 1
            HStack {
                Text("Today is...")
                    .fontWeight(.bold)
                    .shadow(color: .white, radius: 10.0)
                Spacer()
            }
            .padding(.leading)
            
              
                VStack {
                    
                    Spacer()
                    
                    // Row 2; today's date, marquee text
                    HStack {
                        
                        Spacer()
                        
                        Text(dateText)
                            .font(Font(dateFont))
                            .lineLimit(1)
                            .frame(width: 1.1 * dateWidth, height: size.lineHeight)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 5)))
                            .foregroundColor(.blue)

                        Spacer()
                        
                        if eventManager.marquee != nil {
                            MarqueeView(controller: eventManager.marquee)
                                .frame(width: 0.9 * (size.width - dateWidth), height: size.lineHeight)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 5)))
                        } else {
                            Color(.clear)
                                .frame(width: 0.9 * (size.width - dateWidth), height: size.lineHeight)
                        }
                        
                        Spacer()
                    } // End of row 2 HStack
                    
                    Spacer()
                    
                    // Row 3; TimeTicks
                    TimeTickBar(size: size)
                    
                    Spacer()
                }
                .frame(width: size.width, height: size.lineHeight * 3)
                .background(.blue)
                .environmentObject(size)
            
        } // End of main VStack
    }
}


