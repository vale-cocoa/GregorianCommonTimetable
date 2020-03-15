//
//  GregorianCommonTimetableTests
//  LargestDistanceTests.swift
//  
//  Created by Valeriano Della Longa on 13/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
@testable import GregorianCommonTimetable
import Schedule
import Foundation

final class LargestDistanceTests: XCTestCase {
    var kind: GregorianCommonTimetable.Kind!
    var dateInterval: DateInterval!
    
    let refDate = Date(timeIntervalSinceReferenceDate: 0)
    
    // MARK: - Tests lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        kind = nil
        dateInterval = nil
    }
    
    // MARK: - Tests
    // MARK: - kind == .hourlyBased Tests
    func test_whenKindIsHourlyBased_DateIntervalDurationLessThanOneDay_returnsNil()
    {
        // given
        let lessThan1DayDuration: TimeInterval = 3600 - 1
            
        // when
        kind = .hourlyBased
        dateInterval = DateInterval(start: refDate, duration: lessThan1DayDuration)
        
        // then
        XCTAssertNil(largestDistance(for: dateInterval, kindOfGenerator: kind))
    }
    
    func test_whenKindIsHourlyBased_DateIntervalDurationLessThan7Days_returnsExpectedValue()
    {
        // given
        let lessThan7DaysDuration: TimeInterval = 3600*24*7 - 1
        let expectedResult: (component: Calendar.Component, amount: Int) = (.day, 6)
        
        // when
        kind = .hourlyBased
        dateInterval = DateInterval(start: refDate, duration: lessThan7DaysDuration)
        let result = largestDistance(for: dateInterval, kindOfGenerator: kind)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.component, expectedResult.component)
        XCTAssertEqual(result?.amount, expectedResult.amount)
    }
    
    func test_whenKindIsHourlyBased_DateIntervalDurationIsThreeWeeks_returnsExpectedValue()
    {
        // given
        let dc = DateComponents(day: 6, hour: 23, minute: 59, second: 59, weekOfYear: 3)
        let endDate = Calendar.gregorianCalendar.date(byAdding: dc, to: refDate)!
        let expectedResult: (component: Calendar.Component, amount: Int) = (.weekOfYear, 3)
        
        // when
        kind = .hourlyBased
        dateInterval = DateInterval(start: refDate, end: endDate)
        let result = largestDistance(for: dateInterval, kindOfGenerator: kind)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.component, expectedResult.component)
        XCTAssertEqual(result?.amount, expectedResult.amount)
    }
    
    func test_whenKindIsHourlyBased_DateIntervalDurationIsLessThanOneYear_returnsExpectedValue()
    {
        // given
        let dc = DateComponents(month: 11, day: 30, hour: 23, minute: 59, second: 59)
        let endDate = Calendar.gregorianCalendar.date(byAdding: dc, to: refDate)!
        let expectedResult: (component: Calendar.Component, amount: Int) = (.month, 11)
        
        // when
        kind = .hourlyBased
        dateInterval = DateInterval(start: refDate, end: endDate)
        let result = largestDistance(for: dateInterval, kindOfGenerator: kind)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.component, expectedResult.component)
        XCTAssertEqual(result?.amount, expectedResult.amount)
    }
    
    func test_whenKindIsHourlyBased_DateIntervalDurationIsMoreThanOneYear_returnsExpectedValue()
    {
        // given
        let dc = DateComponents(year: 2, month: 11, day: 30, hour: 23, minute: 59, second: 59)
        let endDate = Calendar.gregorianCalendar.date(byAdding: dc, to: refDate)!
        let expectedResult: (component: Calendar.Component, amount: Int) = (.year, 2)
        
        // when
        kind = .hourlyBased
        dateInterval = DateInterval(start: refDate, end: endDate)
        let result = largestDistance(for: dateInterval, kindOfGenerator: kind)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.component, expectedResult.component)
        XCTAssertEqual(result?.amount, expectedResult.amount)
    }
    
    // MARK: - kind == .weekdayBased Tests
    func test_whenKindIsWeekdayBased_DateIntervalDurationLessThan7Days_returnsNil()
    {
        // given
        let lessThan7DaysDuration: TimeInterval = 3600*24*7 - 1
            
        // when
        kind = .weekdayBased
        dateInterval = DateInterval(start: refDate, duration: lessThan7DaysDuration)
        
        // then
        XCTAssertNil(largestDistance(for: dateInterval, kindOfGenerator: kind))
    }
    
    func test_whenKindIsWeekdayBased_DateIntervalDurationIsThreeWeeks_returnsExpectedValue()
    {
        // given
        let dc = DateComponents(day: 6, hour: 23, minute: 59, second: 59, weekOfYear: 3)
        let endDate = Calendar.gregorianCalendar.date(byAdding: dc, to: refDate)!
        let expectedResult: (component: Calendar.Component, amount: Int) = (.weekOfYear, 3)
        
        // when
        kind = .weekdayBased
        dateInterval = DateInterval(start: refDate, end: endDate)
        let result = largestDistance(for: dateInterval, kindOfGenerator: kind)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.component, expectedResult.component)
        XCTAssertEqual(result?.amount, expectedResult.amount)
    }
    
    func test_whenKindIsWeekdayBased_DateIntervalDurationIsLessThanOneYear_returnsExpectedValue()
    {
        // given
        let dc = DateComponents(month: 11, day: 30, hour: 23, minute: 59, second: 59)
        let endDate = Calendar.gregorianCalendar.date(byAdding: dc, to: refDate)!
        let expectedResult: (component: Calendar.Component, amount: Int) = (.month, 11)
        
        // when
        kind = .weekdayBased
        dateInterval = DateInterval(start: refDate, end: endDate)
        let result = largestDistance(for: dateInterval, kindOfGenerator: kind)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.component, expectedResult.component)
        XCTAssertEqual(result?.amount, expectedResult.amount)
    }
    
    func test_whenKindIsWeekdayBased_DateIntervalDurationIsMoreThanOneYear_returnsExpectedValue()
    {
        // given
        let dc = DateComponents(year: 2, month: 11, day: 30, hour: 23, minute: 59, second: 59)
        let endDate = Calendar.gregorianCalendar.date(byAdding: dc, to: refDate)!
        let expectedResult: (component: Calendar.Component, amount: Int) = (.year, 2)
        
        // when
        kind = .weekdayBased
        dateInterval = DateInterval(start: refDate, end: endDate)
        let result = largestDistance(for: dateInterval, kindOfGenerator: kind)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.component, expectedResult.component)
        XCTAssertEqual(result?.amount, expectedResult.amount)
    }
    
    // MARK: - kind == .monthlyBased Tests
    func test_whenKindIsMonthlyBased_DateIntervalDurationIsLessThanOneYear_returnsNil()
    {
        // given
        let dc = DateComponents(month: 11, day: 30, hour: 23, minute: 59, second: 59)
        let endDate = Calendar.gregorianCalendar.date(byAdding: dc, to: refDate)!
        
        // when
        kind = .monthlyBased
        dateInterval = DateInterval(start: refDate, end: endDate)
        
        // then
        XCTAssertNil(largestDistance(for: dateInterval, kindOfGenerator: kind))
    }
    
    func test_whenKindIsMonthly_DateIntervalDurationIsMoreThanOneYear_returnsExpectedValue()
    {
        // given
        let dc = DateComponents(year: 2, month: 11, day: 30, hour: 23, minute: 59, second: 59)
        let endDate = Calendar.gregorianCalendar.date(byAdding: dc, to: refDate)!
        let expectedResult: (component: Calendar.Component, amount: Int) = (.year, 2)
        
        // when
        kind = .monthlyBased
        dateInterval = DateInterval(start: refDate, end: endDate)
        let result = largestDistance(for: dateInterval, kindOfGenerator: kind)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.component, expectedResult.component)
        XCTAssertEqual(result?.amount, expectedResult.amount)
    }
    
    static var allTests = [
        ("test_whenKindIsHourlyBased_DateIntervalDurationLessThanOneDay_returnsNil", test_whenKindIsHourlyBased_DateIntervalDurationLessThanOneDay_returnsNil),
        ("test_whenKindIsHourlyBased_DateIntervalDurationLessThan7Days_returnsExpectedValue", test_whenKindIsHourlyBased_DateIntervalDurationLessThan7Days_returnsExpectedValue),
        ("test_whenKindIsHourlyBased_DateIntervalDurationIsThreeWeeks_returnsExpectedValue", test_whenKindIsHourlyBased_DateIntervalDurationIsThreeWeeks_returnsExpectedValue),
        ("test_whenKindIsHourlyBased_DateIntervalDurationIsLessThanOneYear_returnsExpectedValue", test_whenKindIsHourlyBased_DateIntervalDurationIsLessThanOneYear_returnsExpectedValue),
        ("test_whenKindIsHourlyBased_DateIntervalDurationIsMoreThanOneYear_returnsExpectedValue", test_whenKindIsHourlyBased_DateIntervalDurationIsMoreThanOneYear_returnsExpectedValue),
        ("test_whenKindIsHourlyBased_DateIntervalDurationIsMoreThanOneYear_returnsExpectedValue", test_whenKindIsHourlyBased_DateIntervalDurationIsMoreThanOneYear_returnsExpectedValue),
        ("test_whenKindIsWeekdayBased_DateIntervalDurationLessThan7Days_returnsNil", test_whenKindIsWeekdayBased_DateIntervalDurationLessThan7Days_returnsNil),
        ("test_whenKindIsWeekdayBased_DateIntervalDurationIsThreeWeeks_returnsExpectedValue", test_whenKindIsWeekdayBased_DateIntervalDurationIsThreeWeeks_returnsExpectedValue),
        ("test_whenKindIsWeekdayBased_DateIntervalDurationIsLessThanOneYear_returnsExpectedValue", test_whenKindIsWeekdayBased_DateIntervalDurationIsLessThanOneYear_returnsExpectedValue),
        ("test_whenKindIsWeekdayBased_DateIntervalDurationIsMoreThanOneYear_returnsExpectedValue", test_whenKindIsWeekdayBased_DateIntervalDurationIsMoreThanOneYear_returnsExpectedValue),
        ("test_whenKindIsMonthlyBased_DateIntervalDurationIsLessThanOneYear_returnsNil", test_whenKindIsMonthlyBased_DateIntervalDurationIsLessThanOneYear_returnsNil),
        ("test_whenKindIsMonthly_DateIntervalDurationIsMoreThanOneYear_returnsExpectedValue", test_whenKindIsMonthly_DateIntervalDurationIsMoreThanOneYear_returnsExpectedValue),
        
    ]
}
