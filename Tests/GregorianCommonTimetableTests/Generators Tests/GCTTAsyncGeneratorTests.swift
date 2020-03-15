//
//  GregorianCommonTimetableTests
//  GCTTAsyncGeneratorTests.swift
//
//  Created by Valeriano Della Longa on 13/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
@testable import GregorianCommonTimetable
import Schedule

final class GCTTAsyncGeneratorTests: XCTestCase {
    var kind: GregorianCommonTimetable.Kind!
    var onScheduleValues: Set<Int>!
    var sut: Schedule.AsyncGenerator!
    
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
    
    // MARK: - Tests
    
    func test_completionExecutes() {
        // given
        let whenCases: [() -> Void] = GregorianCommonTimetable.Kind.allCases
            .map {
                let timetable = try! GregorianCommonTimetable(kind: $0, onSchedule: Set())
                
                return {
                    self.kind = timetable.kind
                    self.onScheduleValues = timetable.onScheduleValues
                    self.sut = timetable._asyncGenerator
                }
        }
        
        for when in whenCases
        {
            // when
            when()
            
            let dateInterval = DateInterval(start: .distantPast, end: .distantFuture)
            let exp = expectation(description: "completion executes")
            var completionExecuted = false
            sut(dateInterval, nil) { _ in
                completionExecuted = true
                exp.fulfill()
            }
            
            // then
            wait(for: [exp], timeout: 0.2)
            XCTAssertTrue(completionExecuted)
        }
    }
    
    func test_whenQueueNotNil_completionExecutesOnGivenQueue()
    {
        // given
        let whenCases: [() -> Void] = GregorianCommonTimetable.Kind.allCases
            .map {
                let timetable = try! GregorianCommonTimetable(kind: $0, onSchedule: Set())
                
                return {
                    self.kind = timetable.kind
                    self.onScheduleValues = timetable.onScheduleValues
                    self.sut = timetable._asyncGenerator
                }
        }
        
        for when in whenCases
        {
            // when
            when()
            
            let dateInterval = DateInterval(start: .distantPast, end: .distantFuture)
            let exp = expectation(description: "completion executes")
            var thread: Thread!
            sut(dateInterval, .main) { _ in
                thread = Thread.current
                exp.fulfill()
            }
            
            // then
            wait(for: [exp], timeout: 0.2)
            XCTAssertEqual(thread, .main)
        }
    }
    
    func test_whenScheduleGeneratorIsEmpty_returnsSuccess()
    {
        // given
        let whenCases: [() -> Void] = GregorianCommonTimetable.Kind.allCases
            .map {
                let timetable = try! GregorianCommonTimetable(kind: $0, onSchedule: Set())
                
                return {
                    self.kind = timetable.kind
                    self.onScheduleValues = timetable.onScheduleValues
                    self.sut = timetable._asyncGenerator
                }
        }
        
        for when in whenCases {
            // when
            when()
            
            let dateInterval = DateInterval(start: .distantPast, end: .distantFuture)
            let exp = expectation(description: "completion executes")
            var result: Result<[DateInterval], Swift.Error>!
            sut(dateInterval, .main) { returnedResult in
                result = returnedResult
                exp.fulfill()
            }
            
            // then
            wait(for: [exp], timeout: 2)
            
            if case .success(let resultElements) = result
            {
                XCTAssertTrue(resultElements.isEmpty)
            } else {
                XCTFail("returned .failure")
            }
        }
    }
    
    func test_whenScheduleElementsDoesntThrow_returnsSuccess()
    {
        // given
        let whenCases: [() -> Void] = GregorianCommonTimetable.Kind.allCases
            .map {
                let timetable = try! GregorianCommonTimetable(kind: $0, onSchedule: Set($0.rangeOfScheduleValues))
                
                return {
                    self.kind = timetable.kind
                    self.onScheduleValues = timetable.onScheduleValues
                    self.sut = timetable._asyncGenerator
                }
        }
        
        for when in whenCases
        {
            // when
            when()
            
            let end = Calendar.gregorianCalendar.date(byAdding: .year, value: 2, to: refDate)!
            let dateInterval = DateInterval(start: refDate, end: end)
            let exp = expectation(description: "completion executes")
            var result: Result<[DateInterval], Swift.Error>!
            sut(dateInterval, .main) { returnedResult in
                result = returnedResult
                exp.fulfill()
            }
            let generator = try! GregorianCommonTimetable.scheduleGenerator(kind: kind, for: onScheduleValues)
            let expectedElements = try! scheduleElements(for: generator, of: kind, in: dateInterval)
            
            // then
            wait(for: [exp], timeout: 2)
            
            if case .success(let resultElements) = result
            {
                XCTAssertEqual(resultElements, expectedElements)
            } else {
                XCTFail("returned .failure")
            }
        }

    }
    
    static var allTests = [
        ("test_completionExecutes", test_completionExecutes),
        ("test_whenQueueNotNil_completionExecutesOnGivenQueue", test_whenQueueNotNil_completionExecutesOnGivenQueue),
        ("test_whenScheduleGeneratorIsEmpty_returnsSuccess", test_whenScheduleGeneratorIsEmpty_returnsSuccess),
        ("test_whenScheduleElementsDoesntThrow_returnsSuccess", test_whenScheduleElementsDoesntThrow_returnsSuccess),
        
    ]
}

