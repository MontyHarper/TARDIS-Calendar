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
        
        Task {
            await updateLabels()
        }
        
        // This notification will update timeTickLabels when the date changes.
        let dayTracker = DayTracker()
        updateWhenCurrentDayChanges = dayTracker.$today
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task {
                    await self.updateLabels()
                }
              }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func updateLabels() async {
        
        var newLabels = [TimeTickLabel]()
        
        for key in LabelKey.allCases {
            
            let newLabel = await TimeTickLabel(labelType: key.type(), labelKey: key)
            newLabels.append(newLabel)
        }
        
        timeTickLabels = newLabels
        
    }
}



