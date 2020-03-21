//
//  GregorianCommonTimetableTests
//  ShiftValueTests.swift
//  
//  Created by Valeriano Della Longa on 20/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
@testable import GregorianCommonTimetable
import Schedule
import Foundation

final class ShiftValueTests: XCTestCase {
    let refDate = Date(timeIntervalSinceReferenceDate: 0)
    
    func largerComponent(for kind: GregorianCommonTimetable.Kind) -> Calendar.Component
    {
        switch kind {
        case .hourlyBased:
            return .day
        case .weekdayBased:
            return .weekOfYear
        case .dailyBased:
            return .month
        case .monthlyBased:
            return .year
        }
    }
    
    // MARK: - tests
    func test_whenScheduleIsEmptyOrContainsValueOutOfRange_returnsNil()
    {
        // given
        let emptySchedule: Set<Int> = []
        for kind in GregorianCommonTimetable.Kind.allCases
        {
            // when
            let outOfRangeValue = kind.rangeOfScheduleValues.last! + 1
            let outOfRangeSchedule = Set(kind.rangeOfScheduleValues.lowerBound...outOfRangeValue)
            
            // then
            for direction in CalendarCalculationMatchingDateDirection.allCases
            {
                XCTAssertNil(shiftValue(for: refDate, in: emptySchedule, of: kind, to: direction))
                XCTAssertNil(shiftValue(for: refDate, in: outOfRangeSchedule, of: kind, to: direction))
            }
        }
    }
    
    func test_on_whenDateComponentValueIsNotInSchedule_returnsNil()
    {
        // given
        for kind in GregorianCommonTimetable.Kind.allCases
        {
            let dateComponentValue = Calendar.gregorianCalendar.component(kind.component, from: refDate)
            // when
            let schedule = Set(kind.rangeOfScheduleValues)
                .filter { $0 != dateComponentValue }
            
            // then
            XCTAssertNil(shiftValue(for: refDate, in: schedule, of: kind, to: .on))
        }
    }
    
    func test_on_whenDateComponentValeIsInSchedule_returnsZero()
    {
        // given
        for kind in GregorianCommonTimetable.Kind.allCases {
            let dateComponentValue = Calendar.gregorianCalendar.component(kind.component, from: refDate)
            
            // when
            let schedule = Set([dateComponentValue])
            
            // then
            XCTAssertEqual(shiftValue(for: refDate, in: schedule, of: kind, to: .on), 0)
        }
    }
    
    func test_firstBefore_whenDateComponentValueIsAfterScheduleElement_returnsExpectedResult()
    {
        // given
        for kind in GregorianCommonTimetable.Kind.allCases
        {
            let componentValue = kind.rangeOfScheduleValues[3]
            let scheduleValue = componentValue - 1
            let date = Calendar.gregorianCalendar.date(bySetting: kind.component, value: componentValue, of: refDate)!
            let expectedResultDate = Calendar.gregorianCalendar.date(bySetting: kind.component, value: scheduleValue, of: refDate)!
            let expectedResultDC = Calendar.gregorianCalendar.dateComponents([kind.durationComponent], from: date, to: expectedResultDate)
            let expectedResult = expectedResultDC.value(for: kind.durationComponent)!
            
            // when
            let schedule = Set([scheduleValue])
            let result = shiftValue(for: date, in: schedule, of: kind, to: .firstBefore)
            
            // then
            XCTAssertEqual(result, expectedResult)
        }
    }
    
    func test_firstBefore_whenScheduledElementIsAfterDateComponentAfter_returnsExpectedValue()
    {
        // given
        for kind in GregorianCommonTimetable.Kind.allCases
        {
            let componentValue = kind.rangeOfScheduleValues[3]
            let scheduleValue = componentValue + 1
            let date = Calendar.gregorianCalendar.date(bySetting: kind.component, value: componentValue, of: refDate)!
            let larger = largerComponent(for: kind)
            let wrapBehindLarger = Calendar.gregorianCalendar.date(byAdding: larger, value: -1, to: refDate)!
            let expectedResultDate = Calendar.gregorianCalendar.date(bySetting: kind.component, value: scheduleValue, of: wrapBehindLarger)!
            let expectedResultDC = Calendar.gregorianCalendar.dateComponents([kind.durationComponent], from: date, to: expectedResultDate)
            let expectedResult = expectedResultDC.value(for: kind.durationComponent)!
            
            // when
            // when
            let schedule = Set([scheduleValue])
            let result = shiftValue(for: date, in: schedule, of: kind, to: .firstBefore)
            
            // then
            XCTAssertEqual(result, expectedResult)
        }
    }
    
    func test_firstAfter_whenDateComponentValueIsBeforeScheduleElement_returnsExpectedResult()
    {
        // given
        for kind in GregorianCommonTimetable.Kind.allCases {
            let componentValue = kind.rangeOfScheduleValues[3]
            let scheduleValue = componentValue + 1
            let date = Calendar.gregorianCalendar.date(bySetting: kind.component, value: componentValue, of: refDate)!
            let expectedResultDate = Calendar.gregorianCalendar.date(byAdding: kind.durationComponent, value: 1, to: date)!
            let expectedResultDC = Calendar.gregorianCalendar.dateComponents([kind.durationComponent], from: date, to: expectedResultDate)
            let expectedResult = expectedResultDC.value(for: kind.durationComponent)!
            
            // when
            let schedule = Set([scheduleValue])
            let result = shiftValue(for: date, in: schedule, of: kind, to: .firstAfter)
            
            // then
            XCTAssertEqual(result, expectedResult)
        }
    }
    
    func test_firstAfter_whenDateComponentValueIsAfterScheduleValue_returnsExpectedResult()
    {
        // given
        for kind in GregorianCommonTimetable.Kind.allCases {
            let componentValue = kind.rangeOfScheduleValues[3]
            let scheduleValue = componentValue - 1
            let date = Calendar.gregorianCalendar.date(bySetting: kind.component, value: componentValue, of: refDate)!
            let larger = largerComponent(for: kind)
            let wrappedAfterLarger = Calendar.gregorianCalendar.date(byAdding: larger, value: 1, to: refDate)!
            let expectedResultDate = Calendar.gregorianCalendar.date(bySetting: kind.component, value: scheduleValue, of: wrappedAfterLarger)!
            let expectedResultDC = Calendar.gregorianCalendar.dateComponents([kind.durationComponent], from: date, to: expectedResultDate)
            let expectedResult = expectedResultDC.value(for: kind.durationComponent)!
            
            // when
            let schedule = Set([scheduleValue])
            let result = shiftValue(for: date, in: schedule, of: kind, to: .firstAfter)
            
            // then
            XCTAssertEqual(result, expectedResult)
        }
    }
    
    static var allTests = [
        ("test_whenScheduleIsEmptyOrContainsValueOutOfRange_returnsNil", test_whenScheduleIsEmptyOrContainsValueOutOfRange_returnsNil),
        ("test_on_whenDateComponentValueIsNotInSchedule_returnsNil", test_on_whenDateComponentValueIsNotInSchedule_returnsNil),
        ("test_on_whenDateComponentValeIsInSchedule_returnsZero", test_on_whenDateComponentValeIsInSchedule_returnsZero),
        ("test_firstBefore_whenDateComponentValueIsAfterScheduleElement_returnsExpectedResult", test_firstBefore_whenDateComponentValueIsAfterScheduleElement_returnsExpectedResult),
        ("test_firstBefore_whenScheduledElementIsAfterDateComponentAfter_returnsExpectedValue", test_firstBefore_whenScheduledElementIsAfterDateComponentAfter_returnsExpectedValue),
        ("test_firstAfter_whenDateComponentValueIsBeforeScheduleElement_returnsExpectedResult", test_firstAfter_whenDateComponentValueIsBeforeScheduleElement_returnsExpectedResult),
        ("test_firstAfter_whenDateComponentValueIsAfterScheduleValue_returnsExpectedResult", test_firstAfter_whenDateComponentValueIsAfterScheduleValue_returnsExpectedResult),
        
    ]
}
