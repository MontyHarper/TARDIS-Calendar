//
//  LabelManager.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 3/15/24.
//

import Combine
import SwiftUI

class LabelManager: ObservableObject {
    
    @Published var timeTickLabels = [TimeTickLabel]() {
        didSet {
            print("New TimeTickLabels")
        }
    }
    var updateWhenCurrentDayChanges: AnyCancellable?
    
    var timer: Timer?
    
    init() {
        
        updateLabels()
        
        
        // This notification will update timeTickLabels when the date changes.
        let dayTracker = DayTracker()
        updateWhenCurrentDayChanges = dayTracker.$today
            .sink { _ in self.updateLabels() }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func updateLabels() {
        
        var newLabels = [TimeTickLabel]()
                
        for key in LabelKey.allCases {
            
            let newLabel = TimeTickLabel(labelType: key.type(), labelKey: key)
            newLabels.append(newLabel)
        }
        
        
        DispatchQueue.main.async {
            self.timeTickLabels = newLabels
            
        }
    }
}



