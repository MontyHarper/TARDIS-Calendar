//
//  TimeTickLabel.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 3/16/24.
//

import SwiftUI

struct TimeTickLabel: Comparable {

    var labelType: LabelType
    var labelKey: LabelKey
    var labelText: String
    
    var offset: Double = 0.0
    var absoluteTime: Double = 0.0
    
    init(labelType: LabelType, labelKey: LabelKey) async {
        self.labelType = labelType
        self.labelKey = labelKey
        let rawText = labelKey.rawValue
        self.labelText = rawText.last == "2" ? String(rawText.dropLast()) : rawText
        self.offset = await calculateOffset()
        self.absoluteTime = await calculateAbsoluteTime()
    }
    
    // MARK: - Methods
    // TimeTickLabels are initialized so that they present simple values that will not need recalculating when accessed.
    // Recalculations must be done once per day in order to keep labels matched with current days showing onscreen.
    // Updates are triggered from the LabelManager.
    
    func calculateOffset() async -> Double {
        
        let today = Timeline.calendar.component(.weekday, from: Date.now)
        
        return getOffset()
        
        func weekDayOffset(for daynumber: Int) -> Double {
            let daysAway = (daynumber - today < 0) ? daynumber - today + 14 : daynumber - today
            return Double(12*60*60 + daysAway * 24*60*60)
        }
        
        func getOffset() -> Double {
            switch labelKey {
            case .Now: return 0.0
            case .HalfHour: return 30*60
            case .OneHour: return 60*60
            case .TwoHours: return 2*60*60
            case .ThreeHours: return 3*60*60
            case .FourHours: return 4*60*60
            case .SixHours: return 6*60*60
            case .EightHours: return 8*60*60
            case .ThisMorning: return 9*60*60
            case .NoonToday: return 12*60*60
            case .ThisAfternoon: return 15*60*60
            case .ThisEvening: return 18*60*60
            case .Tonight: return 21*60*60
            case .Midnight: return 24*60*60
            case .TomorrowMorning: return 30*60*60
            case .NoonTomorrow: return 36*60*60
            case .TomorrowAfternoon: return 39*60*60
            case .TomorrowEvening: return 42*60*60
            case .TomorrowNight: return 45*60*60
            case .Sunday: return weekDayOffset(for: 1)
            case .Monday: return weekDayOffset(for: 2)
            case .Tuesday: return weekDayOffset(for: 3)
            case .Wednesday: return weekDayOffset(for: 4)
            case .Thursday: return weekDayOffset(for: 5)
            case .Friday: return weekDayOffset(for: 6)
            case .Saturday: return weekDayOffset(for: 7)
            case .Sunday2: return weekDayOffset(for: 8)
            case .Monday2: return weekDayOffset(for: 9)
            case .Tuesday2: return weekDayOffset(for: 10)
            case .Wednesday2: return weekDayOffset(for: 11)
            case .Thursday2: return weekDayOffset(for: 12)
            case .Friday2: return weekDayOffset(for: 13)
            case .Saturday2: return weekDayOffset(for: 14)
            }
        }
        
    }
    
    func calculateAbsoluteTime() async -> Double {
        
        let now = Date.now.timeIntervalSince1970
        let startOfDay = Timeline.calendar.startOfDay(for: Date.now).timeIntervalSince1970
        
        switch labelType {
        case .hour:
            return now + offset
        case .relative:
            return startOfDay + offset
        case .weekday:
            return startOfDay + offset
        case .now:
            return now
        }
    }
    
    static func < (lhs: TimeTickLabel, rhs: TimeTickLabel) -> Bool {
        lhs.absoluteTime < rhs.absoluteTime
    }
}

enum LabelType {
    case hour
    case relative
    case weekday
    case now
}

enum LabelKey: String, CaseIterable {
    case Now = "NOW"
    case HalfHour = "Half an Hour"
    case OneHour = "One Hour"
    case TwoHours = "Two Hours"
    case ThreeHours = "Three Hours"
    case FourHours = "Four Hours"
    case SixHours = "Six Hours"
    case EightHours = "Eight Hours"
    case ThisMorning = "This Morning"
    case NoonToday = "Noon Today"
    case ThisAfternoon = "This Afternoon"
    case ThisEvening = "This Evening"
    case Tonight
    case Midnight
    case TomorrowMorning = "Tomorrow Morning"
    case NoonTomorrow = "Noon Tomorrow"
    case TomorrowAfternoon = "Tomorrow Afternoon"
    case TomorrowEvening = "Tomorrow Evening"
    case TomorrowNight = "Tomorrow Night"
    case Sunday
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday2
    case Monday2
    case Tuesday2
    case Wednesday2
    case Thursday2
    case Friday2
    case Saturday2
    
    func type() -> LabelType {
        switch self {
        case .Now: return .now
        case .HalfHour: return .hour
        case .OneHour: return .hour
        case .TwoHours: return .hour
        case .ThreeHours: return .hour
        case .FourHours: return .hour
        case .SixHours: return .hour
        case .EightHours: return .hour
        case .ThisMorning: return .relative
        case .NoonToday: return .relative
        case .ThisAfternoon: return .relative
        case .ThisEvening: return .relative
        case .Tonight: return .relative
        case .Midnight: return .relative
        case .TomorrowMorning: return .relative
        case .NoonTomorrow: return .relative
        case .TomorrowAfternoon: return .relative
        case .TomorrowEvening: return .relative
        case .TomorrowNight: return .relative
        case .Sunday: return .weekday
        case .Monday: return .weekday
        case .Tuesday: return .weekday
        case .Wednesday: return .weekday
        case .Thursday: return .weekday
        case .Friday: return .weekday
        case .Saturday: return .weekday
        case .Sunday2: return .weekday
        case .Monday2: return .weekday
        case .Tuesday2: return .weekday
        case .Wednesday2: return .weekday
        case .Thursday2: return .weekday
        case .Friday2: return .weekday
        case .Saturday2: return .weekday
        }
    }
    
}


