//
//  GregorianCommonTimetableTests
//  ShiftDaysValueTests.swift
//  
//  Created by Valeriano Della Longa on 20/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
@testable import GregorianCommonTimetable
import Schedule
import Foundation

final class ShiftDaysValueTests: XCTestCase {
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
    }
    
    func test_on_whenScheduleDoesntIncludeDateDayValue_returnsNil()
    {
        // given
        let fullSchedule = Set(GregorianCommonTimetable.Kind.dailyBased.rangeOfScheduleValues)
        let dateDayValue = Calendar.gregorianCalendar.component(.day, from: refDate)
        // when
        let schedule = fullSchedule
            .filter { $0 != dateDayValue }
        
        // then
        XCTAssertNil(shiftDaysValue(from: refDate, in: schedule, to: .on))
    }
    
    func test_on_whenScheduleIncludesLastDayOfMonthDateDayValueIsLastDayOfDateMonth_returnsZero()
    {
        // given
        let february = Calendar.gregorianCalendar.date(bySetting: .month, value: 2, of: refDate)!
        let rangeOfDays = Calendar.gregorianCalendar.range(of: .day, in: .month, for: february)!
        
        // when
        let schedule = Set([31])
        let date = Calendar.gregorianCalendar.date(bySetting: .day, value: rangeOfDays.last!, of: february)!
        
        // then
        XCTAssertEqual(shiftDaysValue(from: date, in: schedule, to: .on), 0)
    }
    
    func test_on_whenScheduleContaisDateDayValue_returnsZero()
    {
        // given
        let dateDay = Calendar.gregorianCalendar.component(.day, from: refDate)
        
        // when
        let schedule = Set([dateDay])
        
        // then
        XCTAssertEqual(shiftDaysValue(from: refDate, in: schedule, to: .on), 0)
    }
    
    func test_firstBefore_whenScheduleContainsElementSmallerThanDateDay_returnsExpectedResult()
    {
        // given
        // when
        let refDateDay = Calendar.gregorianCalendar.component(.day, from: refDate)
        let dateDay = refDateDay + 1
        let date = Calendar.gregorianCalendar.date(bySetting: .day, value: dateDay, of: refDate)!
        let schedule = Set([1])
        let expectedResult = Calendar.gregorianCalendar.dateComponents([.day], from: date, to: refDate).day!
        
        // then
        XCTAssertEqual(shiftDaysValue(from: date, in: schedule, to: .firstBefore), expectedResult)
    }
    
    func test_firstBefore_whenScheduleDoesntContainElementSmallerThanDateDayButContainsLastMonthDay_returnsDistanceToLastDayOfPreviousMonth()
    {
        // given
        // when
        let schedule = Set([31])
        let baseDateMonth = Calendar.gregorianCalendar.date(bySetting: .month, value: 3, of: refDate)!
        let baseDate = Calendar.gregorianCalendar.date(bySetting: .day, value: 27, of: baseDateMonth)!
        let monthBeforeBaseDate = Calendar.gregorianCalendar.date(byAdding: .month, value: -1, to: baseDate)!
        let lastDayOfMonthBefore = Calendar.gregorianCalendar.range(of: .day, in: .month, for: monthBeforeBaseDate)!.last!
        let expectedResultDate = Calendar.gregorianCalendar.date(bySetting: .day, value: lastDayOfMonthBefore, of: monthBeforeBaseDate)!
        let expectedResult = Calendar.gregorianCalendar.dateComponents([.day], from: baseDate, to: expectedResultDate).day!
        
        let result = shiftDaysValue(from: baseDate, in: schedule, to: .firstBefore)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_firstBefore_whenScheduleDoesntContainElementSmallerThanDateDayNorDoesMonthBeforeContainAnyScheduleElement_returnsExpectedResult()
    {
        // given
        // when
        let schedule = Set([30])
        let baseDateMonth = Calendar.gregorianCalendar.date(bySetting: .month, value: 3, of: refDate)!
        let baseDate = Calendar.gregorianCalendar.date(bySetting: .day, value: 27, of: baseDateMonth)!
        let twoMonthsBeforeBaseDate = Calendar.gregorianCalendar.date(byAdding: .month, value: -2, to: baseDate)!
        let expectedResultDate = Calendar.gregorianCalendar.date(bySetting: .day, value: 30, of: twoMonthsBeforeBaseDate)!
        let expectedResult = Calendar.gregorianCalendar.dateComponents([.day], from: baseDate, to: expectedResultDate).day!
        
        let result = shiftDaysValue(from: baseDate, in: schedule, to: .firstBefore)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_firstAfter_whenScheduleContainsElementGreaterThanDateDay_returnsExpectedResult()
    {
        // given
        // when
        let refDateDay = Calendar.gregorianCalendar.component(.day, from: refDate)
        let dayAfter = refDateDay + 1
        let schedule = Set([dayAfter])
        let expectedResultDate = Calendar.gregorianCalendar.date(bySetting: .day, value: dayAfter, of: refDate)!
        let expectedResult = Calendar.gregorianCalendar.dateComponents([.day], from: refDate, to: expectedResultDate).day!
        let result = shiftDaysValue(from: refDate, in: schedule, to: .firstAfter)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_firstAfter_whenDateDayValueIsntLastDayOfMonthAndScheduleContainsLastDayOfMonthAndScheduleElementIsNotContainedInMonthRange_returnsExpectedResult()
    {
        // given
        // when
        let schedule = Set([30, 31])
        let febrauryDate = Calendar.gregorianCalendar.date(bySetting: .month, value: 2, of: refDate)!
        let lastDay = Calendar.gregorianCalendar.range(of: .day, in: .month, for: febrauryDate)!.last!
        let expectedDateResult = Calendar.gregorianCalendar.date(bySetting: .day, value: lastDay, of: febrauryDate)!
        let expectedResult = Calendar.gregorianCalendar.dateComponents([.day], from: febrauryDate, to: expectedDateResult).day
        let result = shiftDaysValue(from: febrauryDate, in: schedule, to: .firstAfter)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_firstAfter_whenRangeOfDaysForDateDoesntContainScheduleElement_returnsExpectedResult()
    {
        // given
        // when
        let schedule = Set([30])
        let febrauryDate = Calendar.gregorianCalendar.date(bySetting: .month, value: 2, of: refDate)!
        let nextMonth = Calendar.gregorianCalendar.date(byAdding: .month, value: 1, to: febrauryDate)!
        let expectedResultDate = Calendar.gregorianCalendar.date(bySetting: .day, value: 30, of: nextMonth)!
        let expectedResult = Calendar.gregorianCalendar.dateComponents([.day], from: febrauryDate, to: expectedResultDate).day!
        let result = shiftDaysValue(from: febrauryDate, in: schedule, to: .firstAfter)
        
        // then
        XCTAssertEqual(result, expectedResult)
        
    }
    
    static var allTests = [
        ("test_whenNotValidParameters_returnsNil", test_whenNotValidParameters_returnsNil),
        ("test_on_whenScheduleDoesntIncludeDateDayValue_returnsNil", test_on_whenScheduleDoesntIncludeDateDayValue_returnsNil),
        ("test_on_whenScheduleIncludesLastDayOfMonthDateDayValueIsLastDayOfDateMonth_returnsZero", test_on_whenScheduleIncludesLastDayOfMonthDateDayValueIsLastDayOfDateMonth_returnsZero),
        ("test_on_whenScheduleContaisDateDayValue_returnsZero", test_on_whenScheduleContaisDateDayValue_returnsZero),
        ("test_on_whenScheduleContaisDateDayValue_returnsZero", test_on_whenScheduleContaisDateDayValue_returnsZero),
        ("test_firstBefore_whenScheduleContainsElementSmallerThanDateDay_returnsExpectedResult", test_firstBefore_whenScheduleContainsElementSmallerThanDateDay_returnsExpectedResult),
        ("test_firstBefore_whenScheduleContainsElementSmallerThanDateDay_returnsExpectedResult", test_firstBefore_whenScheduleContainsElementSmallerThanDateDay_returnsExpectedResult),
        ("test_firstBefore_whenScheduleDoesntContainElementSmallerThanDateDayButContainsLastMonthDay_returnsDistanceToLastDayOfPreviousMonth", test_firstBefore_whenScheduleDoesntContainElementSmallerThanDateDayButContainsLastMonthDay_returnsDistanceToLastDayOfPreviousMonth),
        ("test_firstBefore_whenScheduleDoesntContainElementSmallerThanDateDayNorDoesMonthBeforeContainAnyScheduleElement_returnsExpectedResult", test_firstBefore_whenScheduleDoesntContainElementSmallerThanDateDayNorDoesMonthBeforeContainAnyScheduleElement_returnsExpectedResult),
        ("test_firstAfter_whenScheduleContainsElementGreaterThanDateDay_returnsExpectedResult", test_firstAfter_whenScheduleContainsElementGreaterThanDateDay_returnsExpectedResult),
        ("test_firstAfter_whenDateDayValueIsntLastDayOfMonthAndScheduleContainsLastDayOfMonthAndScheduleElementIsNotContainedInMonthRange_returnsExpectedResult", test_firstAfter_whenDateDayValueIsntLastDayOfMonthAndScheduleContainsLastDayOfMonthAndScheduleElementIsNotContainedInMonthRange_returnsExpectedResult),
        ("test_firstAfter_whenRangeOfDaysForDateDoesntContainScheduleElement_returnsExpectedResult", test_firstAfter_whenRangeOfDaysForDateDoesntContainScheduleElement_returnsExpectedResult),
        
    ]
}
