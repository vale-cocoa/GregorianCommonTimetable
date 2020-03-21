//
//  GregorianCommonTimetableTests
//  ScheduleElementsTests.swift
//  
//  Created by Valeriano Della Longa on 14/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
@testable import GregorianCommonTimetable
import Schedule
import Foundation

final class ScheduleElementsTests: XCTestCase
{
    let refDate = Date(timeIntervalSinceReferenceDate: 0)
    
    // MARK: - Tests
    // NOTE: This test is disabled since it takes seconds to execute
    // by throttling a thread so that the tested SUT throws meeting
    // the test premise.
    func test_whenGeneratingConcurrentlyExceedsTimeoutLimit_throws()
    {
        // given
        for kind in GregorianCommonTimetable.Kind.allCases
        {
            // when
            let generator = try! mockGregorianGenerator(of: kind, onSchedule: Set(kind.rangeOfScheduleValues), throttle: 1)
            let end = Calendar.gregorianCalendar.date(byAdding: .year, value: 2, to: refDate)!
            let dateInterval = DateInterval(start: refDate, end: end)
            
            // then
            XCTAssertThrowsError(try scheduleElements(for: generator, of: kind, in: dateInterval))
        }
    }
    
    func test_whenChopProducesBothNilChuncks_returnsEmpty()
    {
        // given
        // when
        let dateInterval = DateInterval(start: .distantPast, end: .distantFuture)
        let generator = emptyGenerator
        for kind in GregorianCommonTimetable.Kind.allCases
        {
            XCTAssertTrue(try! scheduleElements(for: generator, of: kind, in: dateInterval).isEmpty)
        }
        
    }
    
    func test_whenChopReturnsSmallestsChunk_returnsSameResultOfGenerateElementsSerially()
    {
        // given
        for kind in GregorianCommonTimetable.Kind.allCases
        {
            let timetable = try! GregorianCommonTimetable(kind: kind, onSchedule: Set(kind.rangeOfScheduleValues))
            var dcToAddForEnd = DateComponents()
            switch kind {
            case .hourlyBased:
                dcToAddForEnd.hour = 23
            case .weekdayBased:
                dcToAddForEnd.day = 6
            case .dailyBased:
                dcToAddForEnd.day = 27
            case .monthlyBased:
                dcToAddForEnd.month = 11
            }
            let end = Calendar.gregorianCalendar.date(byAdding: dcToAddForEnd, to: refDate)!
           
            // when
            let dateInterval = DateInterval(start: refDate, end: end)
            let expectedResult = mockGenerateElementsSerially(generator: timetable._generator, dateInterval: dateInterval)
            
            // then
            XCTAssertEqual(try? scheduleElements(for: timetable._generator, of: kind, in: dateInterval), expectedResult)
        }
    }
    
    func test_whenChopDividesInChuncksDateInterval_returnsSameResultOfGenerateElementsSerially()
    {
        // given
        for kind in GregorianCommonTimetable.Kind.allCases
        {
            let timetable = try! GregorianCommonTimetable(kind: kind, onSchedule: Set(kind.rangeOfScheduleValues))
            var dcToAddForEnd = DateComponents()
            switch kind {
            case .hourlyBased:
                dcToAddForEnd.weekOfYear = 2
            case .weekdayBased:
                dcToAddForEnd.month = 11
            case .dailyBased:
                dcToAddForEnd.month = 2
            case .monthlyBased:
                dcToAddForEnd.year = 2
            }
            let end = Calendar.gregorianCalendar.date(byAdding: dcToAddForEnd, to: refDate)!
           
            // when
            let dateInterval = DateInterval(start: refDate, end: end)
            let expectedResult = mockGenerateElementsSerially(generator: timetable._generator, dateInterval: dateInterval)
            let result = try? scheduleElements(for: timetable._generator, of: kind, in: dateInterval)
            
            var missingElements: [DateInterval] = []
            if let result = result, result.count < expectedResult.count
            {
                missingElements = expectedResult.filter { !result.contains($0) }
            }
            // then
            XCTAssertEqual(result?.count, expectedResult.count, "kind: \(kind), missing elements: \(missingElements)")
            XCTAssertEqual(result, expectedResult, "kind: \(kind)")
        }
    }
    
    static var allTests = [
        ("test_whenGeneratingConcurrentlyExceedsTimeoutLimit_throws", test_whenGeneratingConcurrentlyExceedsTimeoutLimit_throws),
        ("test_whenChopProducesBothNilChuncks_returnsEmpty", test_whenChopProducesBothNilChuncks_returnsEmpty),
        ("test_whenChopReturnsSmallestsChunk_returnsSameResultOfGenerateElementsSerially", test_whenChopReturnsSmallestsChunk_returnsSameResultOfGenerateElementsSerially),
        
    ]
}

fileprivate func mockGenerateElementsSerially(generator: @escaping Schedule.Generator, dateInterval: DateInterval) -> [DateInterval]
{
    let sequence = AnySchedule(body: generator).generate(start: dateInterval.start, end: dateInterval.end)
    return Array(sequence)
}
