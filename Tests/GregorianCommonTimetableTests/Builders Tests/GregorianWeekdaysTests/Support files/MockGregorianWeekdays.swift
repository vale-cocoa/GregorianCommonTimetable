//
//  MockGregorianWeekdays.swift
//  
//
//  Created by Valeriano Della Longa on 22/01/2020.
//

import XCTest
@testable import GregorianCommonTimetable

final class MockGregorianWeekdays {
    let weekdays: GregorianWeekdays
    
    private(set) lazy var containedWeekdays: [Bool] = {
        var _contained = [Bool](repeating: false, count: 7)
        for i in 0..<7 {
            let candidate = GregorianWeekdays(rawValue: 1 << i)
            if self.weekdays.contains(candidate) {
                _contained[i] = true
            }
        }
        
        return _contained
    }()
    
    var inDates: [Date] {
        var dates = [Date]()
        var refDate = Date(timeIntervalSinceReferenceDate: 0)
        for i in 1...6 {
            let weekday = Calendar.gregorianCalendar.component(.weekday, from: refDate)
            if containedWeekdays[weekday - 1] == true {
                dates.append(refDate)
            }
            refDate = Calendar.gregorianCalendar.date(byAdding: .day, value: 1, to: refDate)!
        }
        
        return dates
    }
    
    var outDates: [Date] {
        var dates = [Date]()
        var refDate = Date(timeIntervalSinceReferenceDate: 0)
        for i in 1...6 {
            let weekday = Calendar.gregorianCalendar.component(.weekday, from: refDate)
            if containedWeekdays[weekday - 1] == false {
                dates.append(refDate)
            }
            refDate = Calendar.gregorianCalendar.date(byAdding: .day, value: 1, to: refDate)!
        }
        
        return dates
    }
    
    init() {
        self.weekdays = GregorianWeekdays()
    }
    
    init(_ weekdays: GregorianWeekdays...) {
        var _weekdays = GregorianWeekdays()
        for weekday in weekdays {
            _weekdays.insert(weekday)
        }
        
        self.weekdays = _weekdays
    }
    
    init(randomly: Bool = false) {
        guard
            randomly == true
            else {
                self.weekdays = GregorianWeekdays()
                
                return
        }
        
        var _weekdays = GregorianWeekdays()
        let countOfWeekdays = Int.random(in: 1...7)
        
        for _ in 0..<countOfWeekdays {
            let shift = UInt.random(in: 0..<7)
            let rawValue: UInt = 1 << shift as UInt
            let new = GregorianWeekdays(rawValue: rawValue)
            
            _weekdays.insert(new)
        }
        
        self.weekdays = _weekdays
    }
    
}
