//
//  GregorianCommonTimetableTests
//  GCTTGeneratorTests.swift
//
//  Created by Valeriano Della Longa on 13/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
@testable import GregorianCommonTimetable
import Schedule

final class GCTTGeneratorTests: XCTestCase
{
    var kind: GregorianCommonTimetable.Kind!
    var onScheduleValues: Set<Int>!
    var sut: Schedule.Generator!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        sut = nil
        onScheduleValues = nil
        kind = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    let refDate = Date(timeIntervalSinceReferenceDate: 0)
    
    // MARK: - When
    func whenNotEmptyGeneratorOneValueOnSchedule_cases() -> [() -> Void]
    {
        
        return GregorianCommonTimetable.Kind.allCases
            .map { givenKind in
                let possibleValues = Calendar.gregorianCalendar.maximumRange(of: givenKind.component)!
                let randomElement = Int.random(in: possibleValues)
                let values = Set([randomElement])
                let generator = try! GregorianCommonTimetable.scheduleGenerator(kind: givenKind, for: values)
                
                return {
                    self.kind = givenKind
                    self.onScheduleValues = values
                    self.sut = generator
                }
        }
    }
    func whenNotEmptyGenerator_cases(setRandomlyThreeValues: Bool = false) -> [() -> Void]
    {
        var cases = [() -> Void]()
        for givenKind in GregorianCommonTimetable.Kind.allCases {
            let possibleValues = Calendar.gregorianCalendar.maximumRange(of: givenKind.component)!
            var valuesCombs = [Set<Int>]()
            if setRandomlyThreeValues
            {
                for _ in possibleValues
                {
                    var iterValues = Set<Int>()
                    while iterValues.count < 3 {
                        iterValues.insert(possibleValues.randomElement()!)
                    }
                    valuesCombs.append(iterValues)
                }
            } else {
                valuesCombs = possibleValues
                    .map { Set([$0]) }
            }
            for values in valuesCombs {
                cases.append {
                    self.onScheduleValues = values
                    self.kind = givenKind
                    self.sut = try! GregorianCommonTimetable.scheduleGenerator(kind: self.kind, for: self.onScheduleValues)
                }
            }
        }
        
        return cases
    }
    
    // MARK: Helpers
    private func shiftAmountToFirstAfter(for date: Date) -> Int?
    {
        guard !onScheduleValues.isEmpty else { return nil }
        
        let compValue = Calendar.gregorianCalendar.component(kind.component, from: date)
        let rangeOfComponent = Calendar.gregorianCalendar.maximumRange(of: kind.component)!
        let increment = 1
        var shift = increment
        while shift <= rangeOfComponent.count
        {
            let candidate: Int!
            let incremented = compValue + shift
            if incremented >= rangeOfComponent.upperBound {
                candidate = incremented - (rangeOfComponent.upperBound - rangeOfComponent.lowerBound)
            } else {
                candidate = incremented
            }
            
            if onScheduleValues.contains(candidate) { return shift }
            
            shift += increment
        }
        
        return nil
    }
    
    private func shiftAmountToFirstBefore(for date: Date) -> Int?
    {
        guard !onScheduleValues.isEmpty else { return nil }
        
        let compValue = Calendar.gregorianCalendar.component(kind.component, from: date)
        let rangeOfComponent = Calendar.gregorianCalendar.maximumRange(of: kind.component)!
        let increment = -1
        var shift = increment
        while shift <= rangeOfComponent.count
        {
            let candidate: Int!
            let incremented = compValue + shift
            if incremented < rangeOfComponent.lowerBound {
                candidate = incremented + (rangeOfComponent.upperBound - rangeOfComponent.lowerBound)
            } else {
                candidate = incremented
            }
            
            if onScheduleValues.contains(candidate) { return shift }
            
            shift += increment
        }
        
        return nil
    }
    
    // MARK: - Tests
    // MARK: - direction .on tests
    func test_whenNotEmptyGeneratorOfOneElement_on_returnsExpectedValue()
    {
        // given
        for when in whenNotEmptyGeneratorOneValueOnSchedule_cases()
        {
            // when
            when()
            let possibleValues = Calendar.gregorianCalendar.maximumRange(of: kind.component)!
            let containedDates: [Date] = onScheduleValues
                .compactMap { Calendar.gregorianCalendar.date(bySetting: kind.component, value: $0, of: refDate) }
            let expectedResults = containedDates
                .compactMap { Calendar.gregorianCalendar.dateInterval(of: kind.durationComponent, for: $0) }
            let notContainedDates: [Date] = possibleValues
                .filter { !onScheduleValues.contains($0) }
                .compactMap { Calendar.gregorianCalendar.date(bySetting: kind.component, value: $0, of: refDate) }
            
            // then
            for i in 0..<containedDates.count
            {
                XCTAssertEqual(sut(containedDates[i], .on), expectedResults[i])
            }
            for date in notContainedDates
            {
                XCTAssertNil(sut(date, .on))
            }
        }
    }
    
    func test_whenNotEmptyGeneratorOfThreeElements_on_returnsExpectedValue()
    {
        // given
        for when in whenNotEmptyGeneratorOneValueOnSchedule_cases()
        {
            // when
            when()
            
            let containedDates: [Date] = onScheduleValues
                .compactMap { Calendar.gregorianCalendar.date(bySetting: kind.component, value: $0, of: refDate) }
            let expectedResults = containedDates
                .compactMap { Calendar.gregorianCalendar.dateInterval(of: kind.durationComponent, for: $0) }
            let notContainedDates: [Date] = Calendar.gregorianCalendar.maximumRange(of: kind.component)!
                .filter { !onScheduleValues.contains($0) }
                .compactMap { Calendar.gregorianCalendar.date(bySetting: kind.component, value: $0, of: refDate) }
            
            // then
            for i in 0..<containedDates.count
            {
                XCTAssertEqual(sut(containedDates[i], .on), expectedResults[i])
            }
            for date in notContainedDates
            {
                XCTAssertNil(sut(date, .on))
            }
        }
    }
    
    func test_whenFullScheduleGenerator_on_returnsExpected()
    {
        // given
        for when in whenNotEmptyGenerator_cases()
        {
            // when
            when()
            
            let onDates = onScheduleValues
                .compactMap {  Calendar.gregorianCalendar.date(bySetting: kind.component, value: $0, of: refDate) }
            let expectedResults = onDates
                .map { Calendar.gregorianCalendar.dateInterval(of: kind.durationComponent, for: $0) }
            
            let dateForExpectedResult = zip(onDates, expectedResults)
            for (date, expectedResult) in dateForExpectedResult
            {
                // then
                XCTAssertEqual(sut(date, .on), expectedResult)
            }
        }
    }
    
    // MARK: - direction .firstAfter & .firstBefore test
    func test_whenNotEmptyGeneratorOfOneElement_firstAfterAndFirstBefore_returnsExpectedValue()
    {
        // given
        for when in whenNotEmptyGeneratorOneValueOnSchedule_cases()
        {
            // when
            when()
            let onDate = Calendar.gregorianCalendar.date(bySetting: kind.component, value: onScheduleValues.first!, of: refDate)!
            let onElement = sut(onDate, .on)!
            
            let halfElementDuration = onElement.duration / 2
            
            let dateBeforeScheduledElementStart = Date(timeInterval: -halfElementDuration, since: onElement.start)
            let dateAfterScheduledElementEnd = Date(timeInterval: halfElementDuration, since: onElement.end)
            
            let shiftToNextOn = shiftAmountToFirstAfter(for: dateAfterScheduledElementEnd)!
            let nextOnDate = Calendar.gregorianCalendar.date(byAdding: kind.durationComponent, value: shiftToNextOn, to: dateAfterScheduledElementEnd)!
            let expectedElementAfterOnElement = sut(nextOnDate, .on)
            
            let shiftToPreviousOn = shiftAmountToFirstBefore(for: dateBeforeScheduledElementStart)!
            let previousOnDate = Calendar.gregorianCalendar.date(byAdding: kind.durationComponent, value: shiftToPreviousOn, to: dateBeforeScheduledElementStart)!
            let expectedElementBeforeOnElement = sut(previousOnDate, .on)!
            
            // then
            XCTAssertEqual(sut(dateBeforeScheduledElementStart, .firstAfter), onElement)
            XCTAssertEqual(sut(dateAfterScheduledElementEnd, .firstBefore), onElement)
            XCTAssertEqual(sut(onDate, .firstAfter), expectedElementAfterOnElement)
            XCTAssertEqual(sut(onDate, .firstBefore), expectedElementBeforeOnElement)
        }
    }
    
    func test_whenNotEmptyGeneratorOfThreeElements_firstAfterAndFirstBefore_returnsExpectedValue()
    {
        // given
        for when in whenNotEmptyGenerator_cases(setRandomlyThreeValues: true)
        {
            //when
            when()
            
            var firstAfterExpectedResult: DateInterval? = nil
            if let shift = shiftAmountToFirstAfter(for: refDate)
            {
                let expDate = Calendar.gregorianCalendar.date(byAdding: kind.durationComponent, value: shift, to: refDate)!
                firstAfterExpectedResult = Calendar.gregorianCalendar.dateInterval(of: kind.durationComponent, for: expDate)!
            }
            let firstAfterResult = sut(refDate, .firstAfter)
            
            var firstBeforeExpectedResult: DateInterval? = nil
            if
                let shift = shiftAmountToFirstBefore(for: refDate)
            {
                let expDate = Calendar.gregorianCalendar.date(byAdding: kind.durationComponent, value: shift, to: refDate)!
                firstBeforeExpectedResult = Calendar.gregorianCalendar.dateInterval(of: kind.durationComponent, for: expDate)!
            }
            let firstBeforeResult = sut(refDate, .firstBefore)
            
            // then
            XCTAssertEqual(firstAfterResult, firstAfterExpectedResult, "component: \(kind.component) - value: \(onScheduleValues.first!)")
            XCTAssertEqual(firstBeforeResult, firstBeforeExpectedResult, "component: \(kind.component) - value: \(onScheduleValues.first!)")
            XCTAssertLessThan(firstBeforeResult!.end, firstAfterResult!.start)
            XCTAssertGreaterThan(firstAfterResult!.start, firstBeforeResult!.end)
            
            if let onResult = sut(refDate, .on)
            {
                XCTAssertLessThanOrEqual(firstBeforeResult!.end, onResult.start)
                XCTAssertGreaterThanOrEqual(firstAfterResult!.start, onResult.end)
            }
        }
    }
    
    func test_whenNotEmptyGeneratorOfThreeElements_firstAfterAndFirstBefore_returnedElementsAreInRightOrder()
    {
        // given
        for when in whenNotEmptyGenerator_cases(setRandomlyThreeValues: true)
        {
            // when
            when()
            let orderedValues = Array(onScheduleValues).sorted(by: <)
            let onDate = Calendar.gregorianCalendar.date(bySetting: kind.component, value: orderedValues[1], of: refDate)!
            let onResult = sut(onDate, .on)!
            let firstBeforeResult = sut(onDate, .firstBefore)!
            let firstAfterResult = sut(onDate, .firstAfter)!
            
            // then
            XCTAssertLessThan(firstBeforeResult.start, onResult.start)
            XCTAssertLessThanOrEqual(firstBeforeResult.end, onResult.start)
            XCTAssertGreaterThan(firstAfterResult.start, onResult.start)
            XCTAssertGreaterThanOrEqual(firstAfterResult.start, onResult.end)
            
            // let's also assert for components…
            let onResultStartCompValue = Calendar.gregorianCalendar.component(kind.component, from: onResult.start)
            XCTAssertTrue(onScheduleValues.contains(onResultStartCompValue))
            
            let firstBeforeStartCompValue = Calendar.gregorianCalendar.component(kind.component, from: firstBeforeResult.start)
            XCTAssertTrue(onScheduleValues.contains(firstBeforeStartCompValue))
            
            let firstAfterStartCompValue = Calendar.gregorianCalendar.component(kind.component, from: firstAfterResult.start)
            XCTAssertTrue(onScheduleValues.contains(firstAfterStartCompValue))
        }
    }
    
    func test_whenFullScheduleGenerator_firstAfterAndFirstBefore_returnedElementsAreInRightOrder()
    {
        // given
        for when in whenNotEmptyGenerator_cases()
        {
            // when
            when()
            
            let orderedValues = Array(onScheduleValues).sorted(by: <)
            let onDates = orderedValues
                .compactMap { Calendar.gregorianCalendar.date(bySetting: kind.component, value: $0, of: refDate) }
            for i in 0..<(onDates.count - 1)
            {
                // then
                XCTAssertEqual(sut(onDates[i], .firstAfter), sut(onDates[i+1], .on))
            }
            
            let reversed = onDates.reversed()
            for i in 0..<(reversed.count - 1)
            {
                // then
                XCTAssertEqual(sut(onDates[i], .firstBefore), sut(onDates[i+1], .on))
            }
        }
    }
    
    
    
    static var allTests = [
        ("test_whenNotEmptyGeneratorOfOneElement_on_returnsExpectedValue", test_whenNotEmptyGeneratorOfOneElement_on_returnsExpectedValue),
        ("test_whenNotEmptyGeneratorOfThreeElements_on_returnsExpectedValue", test_whenNotEmptyGeneratorOfThreeElements_on_returnsExpectedValue),
        ("test_whenFullScheduleGenerator_on_returnsExpected", test_whenFullScheduleGenerator_on_returnsExpected),
        ("test_whenNotEmptyGeneratorOfOneElement_firstAfterAndFirstBefore_returnsExpectedValue", test_whenNotEmptyGeneratorOfOneElement_firstAfterAndFirstBefore_returnsExpectedValue),
        ("test_whenNotEmptyGeneratorOfThreeElements_firstAfterAndFirstBefore_returnsExpectedValue", test_whenNotEmptyGeneratorOfThreeElements_firstAfterAndFirstBefore_returnsExpectedValue),
        ("test_whenNotEmptyGeneratorOfThreeElements_firstAfterAndFirstBefore_returnedElementsAreInRightOrder", test_whenNotEmptyGeneratorOfThreeElements_firstAfterAndFirstBefore_returnedElementsAreInRightOrder),
        ("test_whenFullScheduleGenerator_firstAfterAndFirstBefore_returnedElementsAreInRightOrder", test_whenFullScheduleGenerator_firstAfterAndFirstBefore_returnedElementsAreInRightOrder),
        
    ]
}
