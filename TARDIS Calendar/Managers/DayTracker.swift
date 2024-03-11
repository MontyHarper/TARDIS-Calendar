//
//  DayTracker.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 2/26/24.
//

import Combine
import Foundation


class DayTracker: ObservableObject {
    
    @Published var today: Int = Timeline.calendar.dateComponents([.day], from: Date()).day! {
        didSet {
            print("day number: ", today)
        }
    }
    
    private var timer: Timer?
    let calendar = Timeline.calendar
    
    init() {
        setNewTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func setNewTimer() {
        timer?.invalidate()

        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!).timeIntervalSince1970
        let seconds = tomorrow - Date().timeIntervalSince1970 + 5.0
        timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) {_ in
            self.updateToday()
        }
    }
    
    func updateToday() {
        today = Timeline.calendar.dateComponents([.day], from: Date()).day!
        setNewTimer()
    }
}
