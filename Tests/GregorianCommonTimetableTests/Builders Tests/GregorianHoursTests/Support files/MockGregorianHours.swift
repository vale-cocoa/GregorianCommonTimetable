//
//  MockGregorianHours.swift
//  
//
//  Created by Valeriano Della Longa on 18/01/2020.
//

import XCTest
@testable import GregorianCommonTimetable

final class MockGregorianHours {
    let hours: GregorianHoursOfDay
    
    var inDates: [Date] {
        var dates = [Date]()
        var dc = DateComponents(year: 2001, month: 1, day: 1)
        for i in 0..<self.containedHours.count where self.containedHours[i] == true {
            dc.hour = i
            let containedDate = Calendar.gregorianCalendar.date(from: dc)!
            dates.append(containedDate)
        }
        
        return dates
    }
    
    var outDates: [Date] {
        var dates = [Date]()
        var dc = DateComponents(year: 2001, month: 1, day: 1, minute: 30)
        for i in 0..<self.containedHours.count where self.containedHours[i] == false {
            dc.hour = i
            let notContainedDate = Calendar.gregorianCalendar.date(from: dc)!
            dates.append(notContainedDate)
        }
        
        return dates
    }
    
    private(set) lazy var containedHours: [Bool] = {
        var _contained = [Bool](repeating: false, count: 24)
        for i in 0...23 {
            let candidate = GregorianHoursOfDay(rawValue: 1 << i)
            if hours.contains(candidate) {
                _contained[i] = true
            }
        }
            
        return _contained
    }()
    
    init() {
        self.hours = GregorianHoursOfDay()
    }
    
    init(_ hours: UInt...) {
        var _hours = GregorianHours()
        for hour in hours {
            let new = GregorianHoursOfDay(rawValue: hour)
            _hours.insert(new)
        }
        
        self.hours = _hours
    }
    
    init(randomly: Bool) {
        guard randomly == true else {
            self.hours = GregorianHours()
            
            return
        }
        
        var _hours = GregorianHours()
        let countOfScheduledHours = Int.random(in: 0...24)
        
        for _ in 0..<countOfScheduledHours {
            let shift = UInt.random(in: 0..<24)
            let rawValue: UInt = 1 << shift as UInt
            let new = GregorianHoursOfDay(rawValue: rawValue)
            _hours.insert(new)
        }
        self.hours = _hours
    }
}
