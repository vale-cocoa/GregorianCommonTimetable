//
//  GregorianCommonTimetableTests
//  MockGregorianDays.swift
//  
//  Created by Valeriano Della Longa on 21/03/2020.
//

import XCTest
@testable import GregorianCommonTimetable

final class MockGregorianDays {
    let days: GregorianDays
    
    var inDates: [Date] {
        var dates = [Date]()
        var dc = DateComponents(year: 2001, month: 1)
        for i in 0..<self.containedDays.count where self.containedDays[i] == true {
            dc.day = i
            let containedDate = Calendar.gregorianCalendar.date(from: dc)!
            dates.append(containedDate)
        }
        
        return dates
    }
    
    var outDates: [Date] {
        var dates = [Date]()
        var dc = DateComponents(year: 2001, month: 1)
        for i in 0..<self.containedDays.count where self.containedDays[i] == false {
            dc.day = i
            let notContainedDate = Calendar.gregorianCalendar.date(from: dc)!
            dates.append(notContainedDate)
        }
        
        return dates
    }
    
    private(set) lazy var containedDays: [Bool] = {
        var _contained = [Bool](repeating: false, count: 31)
        for i in 0...30 {
            let candidate = GregorianDays(rawValue: 1 << i)
            if days.contains(candidate) {
                _contained[i] = true
            }
        }
            
        return _contained
    }()
    
    init() {
        self.days = GregorianDays()
    }
    
    init(_ days: UInt...) {
        var _days = GregorianDays()
        for day in days {
            let new = GregorianDays(rawValue: day)
            _days.insert(new)
        }
        
        self.days = _days
    }
    
    init(randomly: Bool) {
        guard randomly == true else {
            self.days = GregorianDays()
            
            return
        }
        
        var _days = GregorianDays()
        let countOfScheduledDays = Int.random(in: 0...31)
        
        for _ in 0..<countOfScheduledDays {
            let shift = UInt.random(in: 0..<31)
            let rawValue: UInt = 1 << shift as UInt
            let new = GregorianDays(rawValue: rawValue)
            _days.insert(new)
        }
        self.days = _days
    }
    
}
