//
//  GregorianCommonTimetableTests
//  DaysShiftToAdjacentMonthTests.swift
//  
//  Created by Valeriano Della Longa on 19/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
@testable import GregorianCommonTimetable
import Schedule

final class DaysShiftToAdjacentMonthTests: XCTestCase {
    let refDate = Date(timeIntervalSinceReferenceDate: 0)
    
    func test_whenNotValidParameters_returnsNil() {
        // given
        // when
        let outOfRangeSchedule = Set(1...GregorianCommonTimetable.Kind.dailyBased.rangeOfScheduleValues.upperBound)
        
        // then
        XCTAssertNil(daysShiftToAdjacentMonth(from: refDate, on: outOfRangeSchedule, criteria: .firstBefore))
        XCTAssertNil(daysShiftToAdjacentMonth(from: refDate, on: outOfRangeSchedule, criteria: .firstAfter))
        
        // when
        let emptySchedule = Set<Int>()
        XCTAssertNil(daysShiftToAdjacentMonth(from: refDate, on: emptySchedule, criteria: .firstBefore))
        XCTAssertNil(daysShiftToAdjacentMonth(from: refDate, on: emptySchedule, criteria: .firstAfter))
        
        // when
        let wrongCriteria = CalendarCalculationMatchingDateDirection.on
        let validSchedule = Set(GregorianCommonTimetable.Kind.dailyBased.rangeOfScheduleValues)
        XCTAssertNil(daysShiftToAdjacentMonth(from: refDate, on: validSchedule, criteria: wrongCriteria))
    }
    
    func test_firstAfter_whenNextMonthDayRangeContainsScheduleValue_returnsExpectedResult()
    {
        // given
        let schedule = Set([28])
        let baseDate = Calendar.gregorianCalendar.date(byAdding: .day, value: 27, to: refDate)!
        let expectedResultDate = Calendar.gregorianCalendar.date(byAdding: .month, value: 1, to: baseDate)!
        let expectedResult = Calendar.gregorianCalendar.dateComponents([.day], from: baseDate, to: expectedResultDate).day
        
        // when
        let result = daysShiftToAdjacentMonth(from: baseDate, on: schedule, criteria: .firstAfter)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_firstAfter_whenScheduleValueIsTwoMonthsAhead_returnsExpectedResult()
    {
        // given
        let schedule = Set([30])
        let baseDate = Calendar.gregorianCalendar.date(byAdding: .day, value: 29, to: refDate)!
        let expectedResultDate = Calendar.gregorianCalendar.date(byAdding: .month, value: 2, to: baseDate)!
        let expectedResult = Calendar.gregorianCalendar.dateComponents([.day], from: baseDate, to: expectedResultDate).day
        
        // when
        let result = daysShiftToAdjacentMonth(from: baseDate, on: schedule, criteria: .firstAfter)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_firstBefore_whenPreviousMonthRangeContainsScheduleValue_returnsExpectedResult()
    {
        // given
        let schedule = Set([28])
        let dcToAdd = DateComponents(month: 2, day: 27)
        let baseDate = Calendar.gregorianCalendar.date(byAdding: dcToAdd, to: refDate)!
        let expectedResultDate = Calendar.gregorianCalendar.date(byAdding: .month, value: -1, to: baseDate)!
        let expectedResult = Calendar.gregorianCalendar.dateComponents([.day], from: baseDate, to: expectedResultDate).day
        
        // when
        let result = daysShiftToAdjacentMonth(from: baseDate, on: schedule, criteria: .firstBefore)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_firstBefore_whenScheduleValueIsTwoMonthsEarlier_returnsExpectedResult()
    {
        // given
        let schedule = Set([30])
        let dcToAdd = DateComponents(month: 2, day: 29)
        let baseDate = Calendar.gregorianCalendar.date(byAdding: dcToAdd, to: refDate)!
        let expectedResultDate = Calendar.gregorianCalendar.date(byAdding: .month, value: -2, to: baseDate)!
        let expectedResult = Calendar.gregorianCalendar.dateComponents([.day], from: baseDate, to: expectedResultDate).day
        
        // when
        let result = daysShiftToAdjacentMonth(from: baseDate, on: schedule, criteria: .firstBefore)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    static var allTests = [
        ("test_whenNotValidParameters_returnsNil", test_whenNotValidParameters_returnsNil),
        ("test_firstAfter_whenNextMonthDayRangeContainsScheduleValue_returnsExpectedResult", test_firstAfter_whenNextMonthDayRangeContainsScheduleValue_returnsExpectedResult),
        ("test_firstAfter_whenScheduleValueIsTwoMonthsAhead_returnsExpectedResult", test_firstAfter_whenScheduleValueIsTwoMonthsAhead_returnsExpectedResult),
        ("test_firstBefore_whenPreviousMonthRangeContainsScheduleValue_returnsExpectedResult", test_firstBefore_whenPreviousMonthRangeContainsScheduleValue_returnsExpectedResult),
        ("test_firstBefore_whenPreviousMonthRangeContainsScheduleValue_returnsExpectedResult", test_firstBefore_whenPreviousMonthRangeContainsScheduleValue_returnsExpectedResult),
        ("test_firstBefore_whenScheduleValueIsTwoMonthsEarlier_returnsExpectedResult", test_firstBefore_whenScheduleValueIsTwoMonthsEarlier_returnsExpectedResult),
        
    ]
}
