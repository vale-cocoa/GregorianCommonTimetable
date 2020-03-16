//
//  GregorianMonthsClampedOptionSetTests.swift
//  
//
//  Created by Valeriano Della Longa on 24/01/2020.
//

import XCTest
import VDLCalendarUtilities
@testable import GregorianCommonTimetable

final class GregorianMonthsClampedOptionSetTests: XCTestCase {
    func testMaxRawValue() {
        // given
        let expectedResult = GregorianMonths.year.rawValue
        
        // when
        // then
        XCTAssertEqual(expectedResult, GregorianMonths.maxRawValue)
    }
    
    func testAllBaseValidMemebersAsStrings() {
        // given
        let expectedResult = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        
        // when
        // then
        XCTAssertEqual(expectedResult, GregorianMonths.allBaseValidMembersAsStrings)
    }
    
    func testValidRawValueForString_returnsNil() {
        // given
        let invalidStrings = ["a", "0", "The phrase", "A phrase containig January", "quarter", "half", "entire year"]
        
        // when
        for invalidString in invalidStrings {
            // then
            XCTAssertNil(GregorianMonths.validRawValueForString(invalidString))
        }
    }
    
    func testValidRawValueForString_returnsValidValues() {
        // given
        let validStrings = GregorianMonths.allBaseValidMembersAsStrings + ["firstQuarter", "secondQuarter", "thirdQuarter", "fourthQuarter", "firstHalf", "secondHalf", "year"] + Calendar.gregorianCalendar.shortMonthSymbols
        let uppercased = validStrings.map { $0.uppercased() }
        let expectedResultMonths: [GregorianMonths] = [.january, .february, .march, .april, .may, .june, .july, .august, .september, .october, .november, .december, .firstQuarter, .secondQuarter, .thirdQuarter, .fourthQuarter, .firstHalf, .secondHalf, .year, .january, .february, .march, .april, .may, .june, .july, .august, .september, .october, .november, .december]
        let expectedResult = expectedResultMonths.map { $0.rawValue }
        
        // when
        let resultForValid = validStrings.compactMap { GregorianMonths.validRawValueForString($0) }
        let resultForUppercased = uppercased.compactMap { GregorianMonths.validRawValueForString($0) }
        
        // then
        XCTAssertEqual(expectedResult, resultForValid)
        XCTAssertEqual(expectedResult, resultForUppercased)
    }
    
    func testInitFromString_Throws() {
        // given
        let invalidString = "invalid string"
        
        // when
        // then
        XCTAssertThrowsError(try GregorianMonths(string: invalidString))
    }
    
    func testInitFromString_NoThrows() {
        // given
        let validString = "January"
        
        // when
        // then
        XCTAssertNoThrow(try GregorianMonths(string: validString))
    }
    
    func testInitFromStrings_Throws() {
        // given
        let invalidStrings = ["a", "0", "The phrase", "A phrase containig January", "quarter", "half", "entire year"]
        
        // when
        // then
        XCTAssertThrowsError(try GregorianMonths(strings: invalidStrings))
    }
    
    func testInitFromStrings_NoThrows() {
        // given
        let validStrings = [
            "January", "February", "March", "April",
            "May", "June", "July", "August",
            "September", "October", "November", "December",
            "firstQuarter", "secondQuarter",
            "thirdQuarter", "fourthQuarter",
            "firstHalf", "secondHalf", "year"
        ]
        
        // when
        // then
        XCTAssertNoThrow(try GregorianMonths(strings: validStrings))
    }
    
    func testValidRawValueFromDate() {
        // given
        let refDate = Date(timeIntervalSinceReferenceDate: 0)
        let dates: [Date] = (0..<12).map { Calendar.gregorianCalendar.date(byAdding: .month, value: $0, to: refDate)! }
        let expectedResult: [UInt] = dates.map { date in
            let shift = Calendar.gregorianCalendar.component(.month, from: date) - 1
            
            return (1 << shift) as UInt
        }
        
        // when
        let result = dates.compactMap { GregorianMonths.validRawValueForDate($0) }
        
        // then
        XCTAssertEqual(expectedResult, result)
    }
    
    func testInitFromDate() {
        // given
        let refDate = Date(timeIntervalSinceReferenceDate: 0)
        let dates: [Date] = (0..<12).map { Calendar.gregorianCalendar.date(byAdding: .month, value: $0, to: refDate)! }
        let expectedResult: [GregorianMonths] = dates.map { date in
            let shift = Calendar.gregorianCalendar.component(.month, from: date) - 1
            let rawValue: UInt = (1 << shift) as UInt
            
            return GregorianMonths(rawValue: rawValue)
        }
        
        // when
        let result: [GregorianMonths] = dates.compactMap { GregorianMonths(from: $0) }
        
        // then
        XCTAssertEqual(expectedResult, result)
    }
    
    func testInitFromDates() {
        // given
        let refDate = Date(timeIntervalSinceReferenceDate: 0)
        let countOfDates = Int.random(in: 1...12)
        var dates = [Date]()
        for _ in 0..<countOfDates {
            let monthsToAdd = Int.random(in: 0..<12)
            let randomDate = Calendar.gregorianCalendar.date(byAdding: .month, value: monthsToAdd, to: refDate)!
            dates.append(randomDate)
        }
        let expectedResult: GregorianMonths = dates.reduce(GregorianMonths()) { partial, date in
            let shift = Calendar.gregorianCalendar.component(.month, from: date) - 1
            let rawValue: UInt = (1 << shift) as UInt
            let new = GregorianMonths(rawValue: rawValue)
            
            return partial.union(new)
        }
        
        // when
        let result = GregorianMonths(from: dates)
        
        // then
        XCTAssertEqual(expectedResult, result)
    }
    
    func testContains() {
        // given
        let sut = MockGregorianMonths.init(randomly: true)
        let startDate = Date(timeIntervalSinceReferenceDate: 0)
        let dates: [Date] = (0..<12).map {
            return Calendar.gregorianCalendar.date(byAdding: .month, value: $0, to: startDate)!
        }
        let expectedResult = sut.containedMonths
        
        // when
        let result: [Bool] = dates.map { sut.months.contains(date: $0) }
        
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
