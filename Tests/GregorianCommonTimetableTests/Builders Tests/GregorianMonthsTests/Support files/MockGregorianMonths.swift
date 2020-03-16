//
//  MockGregorianMonths.swift
//  
//
//  Created by Valeriano Della Longa on 24/01/2020.
//

import XCTest
@testable import GregorianCommonTimetable

final class MockGregorianMonths {
    let months: GregorianMonths
    
    private(set) lazy var containedMonths: [Bool] = {
        var contained = [Bool](repeating: false, count: 12)
        for i in 0..<12 {
            let candidate = GregorianMonths(rawValue: 1 << i)
            if self.months.contains(candidate) {
                contained[i] = true
            }
        }
        
        return contained
    }()
    
    var inDates: [Date] {
        var dates = [Date]()
        var refDate = Date(timeIntervalSinceReferenceDate: 0)
        for _ in 1...11 {
            let month = Calendar.gregorianCalendar.component(.month, from: refDate)
            if containedMonths[month - 1] == true {
                dates.append(refDate)
            }
            refDate = Calendar.gregorianCalendar.date(byAdding: .month, value: 1, to: refDate)!
        }
        
        return dates
    }
    
    var outDates: [Date] {
        var dates = [Date]()
        var refDate = Date(timeIntervalSinceReferenceDate: 0)
        for _ in 1...11 {
            let month = Calendar.gregorianCalendar.component(.month, from: refDate)
            if containedMonths[month - 1] == false {
                dates.append(refDate)
            }
            refDate = Calendar.gregorianCalendar.date(byAdding: .month, value: 1, to: refDate)!
        }
        
        return dates
    }
    
    init() {
        self.months = GregorianMonths()
    }
    
    init(_ months: GregorianMonths...) {
        let initMonths = months
            .reduce(GregorianMonths()) { partial, element in
                return partial.union(element)
        }
        
        self.months = initMonths
    }
    
    init(randomly: Bool = false) {
        guard
            randomly == true
            else {
                self.months = GregorianMonths()
                
                return
        }
        
        var _months = GregorianMonths()
        let countOfMonths = Int.random(in: 1...12)
        for _ in 0..<countOfMonths {
            let shift = UInt.random(in: 0..<12)
            let new = GregorianMonths(rawValue: 1 << shift)
            _months.insert(new)
        }
        
        self.months = _months
    }
    
}
