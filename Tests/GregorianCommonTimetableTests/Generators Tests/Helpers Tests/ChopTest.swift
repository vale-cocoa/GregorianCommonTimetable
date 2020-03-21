//
//  GregorianCommonTimetableTests
//  ChopTests.swift
//
//  Created by Valeriano Della Longa on 13/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
@testable import GregorianCommonTimetable
import Schedule

final class ChopTests: XCTestCase {
    var sut: GregorianCommonTimetable!
    var dateInterval: DateInterval!
    
    // MARK: - Tests lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        sut = nil
        dateInterval = nil
        
        super.tearDown()
    }
    
    let refDate = Date(timeIntervalSinceReferenceDate: 0)
    
    // MARK: - Given
    func givenLessThanOneDay() -> DateInterval {
        return DateInterval(start: refDate, duration: (3600*24 - 1))
    }
    
    func givenLessThanOneWeek() -> DateInterval {
        let dc = DateComponents(day: 6, hour: 23, minute: 59, second: 59)
        let end = Calendar.gregorianCalendar.date(byAdding: dc, to: refDate)!
        return DateInterval(start: refDate, end: end)
    }
    
    func givenLessThanOneMonth() -> DateInterval {
        let monthLater = Calendar.gregorianCalendar.date(byAdding: .month, value: 1, to: refDate)!
        let end = Date(timeInterval: -1, since: monthLater)
        return DateInterval(start: refDate, end: end)
    }
    
    func givenLessThanOneYear() -> DateInterval {
        let yearlater = Calendar.gregorianCalendar.date(byAdding: .year, value: 1, to: refDate)!
        let end = Date(timeInterval: -1, since: yearlater)
        return DateInterval(start: refDate, end: end)
    }
    
    func givenTwoYears() -> DateInterval {
        let end = Calendar.gregorianCalendar.date(byAdding: .year, value: 2, to: refDate)!
        return DateInterval(start: refDate, end: end)
    }
    
    // MARK: - When
    func whenEffectiveDateIntervalReturnsNil_cases() -> [() -> Void]
    {
        var cases = [() -> Void]()
        let emptyGeneratorCases: [() -> Void] = GregorianCommonTimetable.Kind.allCases
            .map { kind in
                let timetable = try! GregorianCommonTimetable(kind: kind, onSchedule: [])
                let widest = DateInterval(start: .distantPast, end: .distantFuture)
                return {
                    self.sut = timetable
                    self.dateInterval = widest
                }
        }
        cases.append(contentsOf: emptyGeneratorCases)
        
        let dateIntervalIntersectsSameElementCases: [() -> Void] = GregorianCommonTimetable.Kind.allCases
            .map { kind in
                let onSchedule = Set(kind.rangeOfScheduleValues)
                let timetable = try! GregorianCommonTimetable(kind: kind, onSchedule: onSchedule)
                let onElement = timetable._generator(self.refDate, .firstAfter)!
                
                return {
                    self.sut = timetable
                    self.dateInterval = DateInterval(start: Date(timeInterval: 60, since: onElement.start), end: onElement.end)
                }
        }
        cases.append(contentsOf: dateIntervalIntersectsSameElementCases)
        
        let dateIntervalDoesntContainAnyElementCases: [() -> Void] = GregorianCommonTimetable.Kind.allCases
            .map { kind in
                let possibleCases = kind.rangeOfScheduleValues
                let onSchedule = Set([possibleCases.lowerBound])
                let timetable = try! GregorianCommonTimetable(kind: kind, onSchedule: onSchedule)
                let firstAfter = timetable._generator(refDate, .firstAfter)!
                let start = Date(timeInterval: 60, since: firstAfter.end)
                let afterFirstAfter = timetable._generator(firstAfter.end, .firstAfter)!
                let end = Date(timeInterval: -1, since: afterFirstAfter.start)
                
                return {
                    self.sut = timetable
                    self.dateInterval = DateInterval(start: start, end: end)
                }
        }
        cases.append(contentsOf: dateIntervalDoesntContainAnyElementCases)
        
        return cases
    }
    
    func whenLargestDistanceReturnsNil_cases() -> [() -> Void]
    {
        
        return GregorianCommonTimetable.Kind.allCases
            .map { kind in
            let fullScheduleValues = Set(Calendar.gregorianCalendar.maximumRange(of: kind.component)!)
            let timeTable = try! GregorianCommonTimetable(kind: kind, onSchedule: fullScheduleValues)
            switch kind {
            case .hourlyBased:
                return {
                    self.sut = timeTable
                    self.dateInterval = self.givenLessThanOneDay()
                }
            case .weekdayBased:
                return {
                    self.sut = timeTable
                    self.dateInterval = self.givenLessThanOneWeek()
                }
            case .dailyBased:
                return {
                    self.sut = timeTable
                    self.dateInterval = self.givenLessThanOneMonth()
                }
            case .monthlyBased:
                return {
                    self.sut = timeTable
                    self.dateInterval = self.givenLessThanOneYear()
                }
            }
        }
    }
    
    func whenLargestDistanceReturnsValues_cases() -> [() -> Void]
    {
        return GregorianCommonTimetable.Kind.allCases
            .map { kind in
                let dc: DateComponents = kind.componentsForDistanceCalculation.reduce(DateComponents()) { partial, component in
                    var nextResult = partial
                    nextResult.setValue(2, for: component)
                    
                    return nextResult
                }
                    let end = Calendar.gregorianCalendar.date(byAdding: dc, to: self.refDate)!
                    return {
                        self.sut = try! GregorianCommonTimetable(kind: kind, onSchedule: Set(kind.rangeOfScheduleValues))
                        self.dateInterval = DateInterval(start: self.refDate, end: end)
                    }
        } as [() ->Void]
    }
    
    // MARK: - Tests
    func test_whenEffectiveDateIntervalReturnsNil_returnsNilForBothChuncks()
    {
        // given
        for when in whenEffectiveDateIntervalReturnsNil_cases()
        {
            // when
            when()
            
            let result = chop(dateInterval: dateInterval, for: sut._generator, of: sut.kind)
            
            // then
            XCTAssertNil(result.firstChunk)
            XCTAssertNil(result.secondChunk)
        }
    }
    
    func test_whenLargestDistanceReturnsNil_returnsExpectedResult()
    {
        // given
        for when in whenLargestDistanceReturnsNil_cases()
        {
            // when
            when()
            let expectedResult: (firstChunk: DateInterval?, secondChunk: DateInterval?) = (nil, effectiveDateInterval(from: dateInterval, for: sut._generator))
            
            let result = chop(dateInterval: dateInterval, for: sut._generator, of: sut.kind)
            
            // then
            XCTAssertEqual(result.firstChunk, expectedResult.firstChunk)
            XCTAssertEqual(result.secondChunk, expectedResult.secondChunk)
        }
    }
    
    func test_whenLargestDistanceReturnsValues_returnsExpectedResult()
    {
        // given
        for when in  whenLargestDistanceReturnsValues_cases()
        {
            // when
            when()
            
            let effective = effectiveDateInterval(from: dateInterval, for: sut._generator)!
            
            let distance = largestDistance(for: effective, kindOfGenerator: sut.kind)!
            let distanceEnd = Calendar.gregorianCalendar.date(byAdding: distance.component, value: distance.amount, to: effective.start)!
            let expectedFirstChunckEnd = Calendar.gregorianCalendar.date(byAdding: sut.kind.durationComponent, value: -1, to: distanceEnd)!
            let expectedFirstChunk = DateInterval(start: effective.start, end: expectedFirstChunckEnd)
            
            let expectedSecondChunk = DateInterval(start: expectedFirstChunckEnd, end: dateInterval.end) 
            
            let result = chop(dateInterval: dateInterval, for: sut._generator, of: sut.kind)
            
            // then
            XCTAssertEqual(result.firstChunk, expectedFirstChunk)
            XCTAssertEqual(result.secondChunk, expectedSecondChunk)
            if let secondChunkDuration = result.secondChunk?.duration
            {
                XCTAssertGreaterThan(result.firstChunk!.duration, secondChunkDuration)
            }
        }
    }
    
    static var allTests = [
        ("test_whenEffectiveDateIntervalReturnsNil_returnsNilForBothChuncks", test_whenEffectiveDateIntervalReturnsNil_returnsNilForBothChuncks),
        ("test_whenLargestDistanceReturnsNil_returnsExpectedResult", test_whenLargestDistanceReturnsNil_returnsExpectedResult),
        ("test_whenLargestDistanceReturnsValues_returnsExpectedResult", test_whenLargestDistanceReturnsValues_returnsExpectedResult),
        
    ]
}
