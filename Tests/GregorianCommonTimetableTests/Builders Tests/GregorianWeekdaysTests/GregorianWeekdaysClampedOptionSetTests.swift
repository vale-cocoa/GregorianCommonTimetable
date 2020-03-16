//
//  GregorianWeekdaysClampedOptionSetTests.swift
//  
//
//  Created by Valeriano Della Longa on 22/01/2020.
//

import XCTest
@testable import GregorianCommonTimetable

final class GregorianWeekdaysClampedOptionSetTests: XCTestCase {
    func testMaxRawValue() {
        // given
        let expectedResult = GregorianWeekdays.everyday.rawValue
        
        // when
        // then
        XCTAssertEqual(expectedResult, GregorianWeekdays.maxRawValue)
    }
    
    func testAllBaseValidMemebersAsStrings() {
        // given
        let expectedResult = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        // when
        // then
        XCTAssertEqual(expectedResult, GregorianWeekdays.allBaseValidMembersAsStrings)
    }
    
    func testValidRawValueForString_returnsNil() {
        // given
        let invalidStrings = ["a", "0", "The phrase", "A phrase containig Monday", "weekends", "weekday", "everytime"]
        
        // when
        for invalidString in invalidStrings {
            // then
            XCTAssertNil(GregorianWeekdays.validRawValueForString(invalidString))
        }
        
    }
    
    func testValidRawValueForString_returnsValidValues() {
        // given
        let validStrings = GregorianWeekdays.allBaseValidMembersAsStrings + ["weekend", "weekdays", "everyday"] + Calendar.gregorianCalendar.shortWeekdaySymbols
        let uppercased = validStrings.map { $0.uppercased() }
        let expectedResultWeekdays: [GregorianWeekdays] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .weekend, .weekdays, .everyday, .sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        let expectedResult = expectedResultWeekdays.map { $0.rawValue }
        
        // when
        let resultForValid = validStrings.compactMap { GregorianWeekdays.validRawValueForString($0) }
        let resultForUppercased = uppercased.compactMap { GregorianWeekdays.validRawValueForString($0) }
        
        // then
        XCTAssertEqual(expectedResult, resultForValid)
        XCTAssertEqual(expectedResult, resultForUppercased)
    }
    
    func testInitFromString_Throws() {
        // given
        let invalidString = "invalid string"
        
        // when
        // then
        XCTAssertThrowsError(try GregorianWeekdays(string: invalidString))
    }
    
    func testInitFromString_NoThrows() {
        // given
        let validString = "Monday"
        
        // when
        // then
        XCTAssertNoThrow(try GregorianWeekdays(string: validString))
    }
    
    func testInitFromStrings_Throws() {
        // given
        let invalidStrings = ["a", "0", "The phrase", "A phrase containig Monday", "weekends", "weekday", "everytime"]
        
        // when
        // then
        XCTAssertThrowsError(try GregorianWeekdays(strings: invalidStrings))
    }
    
    func testInitFromStrings_NoThrows() {
        // given
        let validStrings = [
            "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "weekend", "weekdays", "everyday"
        ]
        
        // when
        // then
        XCTAssertNoThrow(try GregorianWeekdays(strings: validStrings))
    }
    
    func testValidRawValueFromDate() {
        // given
        let refDate = Date(timeIntervalSinceReferenceDate: 0)
        let dates: [Date] = (0..<7).map { Calendar.gregorianCalendar.date(byAdding: .day, value: $0, to: refDate)! }
        let expectedResult: [UInt] = dates.map { date in
            let shift = Calendar.gregorianCalendar.component(.weekday, from: date) - 1
            
            return (1 << shift) as UInt
        }
        
        // when
        let result = dates.compactMap { GregorianWeekdays.validRawValueForDate($0) }
        
        // then
        XCTAssertEqual(expectedResult, result)
    }
    
    func testInitFromDate() {
        // given
        let refDate = Date(timeIntervalSinceReferenceDate: 0)
        let dates: [Date] = (0..<7).map { Calendar.gregorianCalendar.date(byAdding: .day, value: $0, to: refDate)! }
        let expectedResult: [GregorianWeekdays] = dates.map { date in
            let shift = Calendar.gregorianCalendar.component(.weekday, from: date) - 1
            let rawValue: UInt = (1 << shift) as UInt
            
            return GregorianWeekdays(rawValue: rawValue)
        }
        
        // when
        let result: [GregorianWeekdays] = dates.compactMap { GregorianWeekdays(from: $0) }
        
        // then
        XCTAssertEqual(expectedResult, result)
    }
    
    func testInitFromDates() {
        // given
        let refDate = Date(timeIntervalSinceReferenceDate: 0)
        let countOfDates = Int.random(in: 1...7)
        var dates = [Date]()
        for _ in 0..<countOfDates {
            let daysToAdd = Int.random(in: 0..<7)
            let randomDate = Calendar.gregorianCalendar.date(byAdding: .day, value: daysToAdd, to: refDate)!
            dates.append(randomDate)
        }
        let expectedResult: GregorianWeekdays = dates.reduce(GregorianWeekdays()) { partial, date in
            let shift = Calendar.gregorianCalendar.component(.weekday, from: date) - 1
            let rawValue: UInt = (1 << shift) as UInt
            let new = GregorianWeekdays(rawValue: rawValue)
            
            return partial.union(new)
        }
        
        // when
        let result = GregorianWeekdays(from: dates)
        
        // then
        XCTAssertEqual(expectedResult, result)
    }
    
    func testContains() {
        // given
        let sut = MockGregorianWeekdays.init(randomly: true)
        let startDate = Date(timeIntervalSinceReferenceDate: 0)
        let dates: [Date] = (0..<7).map {
            return Calendar.gregorianCalendar.date(byAdding: .day, value: $0, to: startDate)!
        }.sorted(by: { lhs, rhs in
            let lhsWeekday = Calendar.gregorianCalendar.component(.weekday, from: lhs)
            let rhsWeekDay = Calendar.gregorianCalendar.component(.weekday, from: rhs)
            
            return lhsWeekday < rhsWeekDay
        })
        let expectedResult = sut.containedWeekdays
        
        // when
        let result: [Bool] = dates.map { sut.weekdays.contains(date: $0) }
        
        // then
        XCTAssertEqual(expectedResult, result)
    }
    
    static var allTests = [
        ("testMaxRawValue", testMaxRawValue),
        ("testAllBaseValidMemebersAsStrings", testAllBaseValidMemebersAsStrings),
        ("testValidRawValueForString_returnsNil", testValidRawValueForString_returnsNil),
        ("testValidRawValueForString_returnsValidValues", testValidRawValueForString_returnsValidValues),
        ("testInitFromString_Throws", testInitFromString_Throws),
        ("testInitFromString_NoThrows", testInitFromString_NoThrows),
        ("testInitFromStrings_Throws", testInitFromStrings_Throws),
        ("testInitFromStrings_NoThrows", testInitFromStrings_NoThrows),
        ("testValidRawValueFromDate", testValidRawValueFromDate),
        ("testInitFromDate", testInitFromDate),
        ("testInitFromDates", testInitFromDates),
        ("testContains", testContains),
        
    ]
}
