//
//  GregorianCommonTimetableTests
//  GregorianDaysClampedOptionSetTests.swift
//  
//
//  Created by Valeriano Della Longa on 20/03/2020.
//

import XCTest
import ClampedOptionSet
@testable import GregorianCommonTimetable

final class GregorianDaysClampedOptionSetTests: XCTestCase
{
    let refDate = Date(timeIntervalSinceReferenceDate: 0)
    
    func test_maxRawValue() {
        // given
        let expectedResult = GregorianDays.everyDay.rawValue
        
        // when
        // then
        XCTAssertEqual(GregorianDays.maxRawValue, expectedResult)
    }
    
    func test_allValidBaseMemebersAsString() {
        // given
        let expectedResult = (1..<32)
            .map { String($0) }
        
        // when
        // then
        XCTAssertEqual(GregorianDays.allBaseValidMembersAsStrings, expectedResult)
    }
    
    func test_validRawValueForString_returnsNil() {
        let invalidStrings = [" ", "52", "A phrase.", "0000", "1234", "A", "#", "24:00am", "24:00"]
        // when
        for invalidString in invalidStrings {
            // then
            XCTAssertNil(GregorianDays.validRawValueForString(invalidString), "\(invalidString) returns a valid rawValue")
        }
    }
    
    func testValidRawValueForString_returnsValidValues() {
        // given
        let inputStrings = (1..<32)
            .map { String($0) }
        let expectedResult = (0..<31)
            .map { UInt(1 << $0) }
        
        // when
        let result = inputStrings
            .compactMap { GregorianDays.validRawValueForString($0) }
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func testInitFromString_Throws() {
        // given
        let invalidString = "invalid string"
        
        // when
        // then
        XCTAssertThrowsError(try GregorianDays(string: invalidString))
    }
    
    func testInitFromString_NoThrows() {
        // given
        let validString = "12"
        
        // when
        // then
        XCTAssertNoThrow(try GregorianDays(string: validString))
    }
    
    func testInitFromStrings_Throws() {
        // given
        let invalidStrings = [" ", "52", "A phrase.", "0000", "1234", "A", "#", "24:00am", "24:00"]
        
        // when
        // then
        XCTAssertThrowsError(try GregorianDays(strings: invalidStrings))
    }
    
    func testInitFromStrings_NoThrows() {
        // given
        let validStrings = (1..<32).map { String($0) }
        
        // when
        // then
        XCTAssertNoThrow(try GregorianDays(strings: validStrings))
    }
    
    func test_validRawValueFromDate() {
        // given
        let expectedResult = (0..<31).map { UInt(1 << $0) }
        var refDateDC = Calendar.gregorianCalendar.dateComponents([.year, .month], from: refDate)
        
        // when
        let result: [UInt] = (1..<32).map { day in
            refDateDC.day = day
            let date = Calendar.gregorianCalendar.date(from: refDateDC)!
            
            return GregorianDays.validRawValueForDate(date)
        }
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_initFromDate() {
        // given
        let dates = (1..<32).compactMap { Calendar.gregorianCalendar.date(bySetting: .day, value: $0, of: refDate) }
        let expectedResult: [GregorianDays] = dates
            .map { date in
                let day = Calendar.gregorianCalendar.component(.day, from: date)
                let shift = day - 1
                let rawValue = UInt(1 << shift)
                
                return GregorianDays(rawValue: rawValue)
        }
        
        // when
        let result = dates.map { GregorianDays(from: $0) }
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_initFromDates() {
        // given
        let givenDates = (1..<32).compactMap { Calendar.gregorianCalendar.date(bySetting: .day, value: $0, of: refDate) }
        let expectedResult = GregorianDays.everyDay
        
        // when
        let result = GregorianDays(from: givenDates)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_contains() {
        // given
        let sut = MockGregorianDays(randomly: true)
        var dc = DateComponents(year: 2001, month: 1)
        let dates: [Date] = (1..<32).map { day in
            dc.day = day
            
            return Calendar.gregorianCalendar.date(from: dc)!
        }
        let expectedResult = sut.containedDays
        
        // when
        let result: [Bool] = dates
            .map { sut.days.contains(date: $0) }
        
        // then
        XCTAssertEqual(expectedResult, result)
    }
    
    static var allTests = [
        ("test_maxRawValue", test_maxRawValue),
        ("test_allValidBaseMemebersAsString", test_allValidBaseMemebersAsString),
        ("test_validRawValueForString_returnsNil", test_validRawValueForString_returnsNil),
        ("testValidRawValueForString_returnsValidValues", testValidRawValueForString_returnsValidValues),
        ("testInitFromString_Throws", testInitFromString_Throws),
        ("testInitFromString_NoThrows", testInitFromString_NoThrows),
        ("testInitFromStrings_Throws", testInitFromStrings_Throws),
        ("testInitFromStrings_NoThrows", testInitFromStrings_NoThrows),
        ("test_validRawValueFromDate", test_validRawValueFromDate),
        ("test_initFromDate", test_initFromDate),
        ("test_initFromDates", test_initFromDates),
        
    ]
}
