//
//  GregorianCommonTimetableTests
//  EffectiveDateIntervalTests.swift
//
//  Created by Valeriano Della Longa on 13/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
@testable import GregorianCommonTimetable
import Schedule
import Foundation

final class EffectiveDateIntervalTests: XCTestCase {
    var sut: GregorianCommonTimetable!
    var dateInterval: DateInterval!
    
    let refDate = Date(timeIntervalSinceReferenceDate: 0)
    
    // MARK: - Tests lifecycle
    override func setUp() {
        super.setUp()
        
        let values =  Set<Int>([1, 3, 5, 6, 7])
        sut = try! GregorianCommonTimetable(kind: .monthlyBased, onSchedule: values)
    }
    
    override func tearDown() {
        sut = nil
        dateInterval = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func test_whenGeneratorIsEmpty_returnsNil()
    {
        XCTAssertNil(effectiveDateInterval(from: DateInterval(start: .distantPast, end: .distantFuture), for: emptyGenerator))
    }
    
    func test_whenDateIntervalIntersectsSameElement_returnsNil()
    {
        // given
        let baseDateInterval = sut._generator(refDate, .firstAfter)!
        let start = Date(timeInterval: 60, since: baseDateInterval.start)
        let end = Date(timeInterval: -60, since: baseDateInterval.end)
        
        // when
        dateInterval = DateInterval(start: start, end: end)
        
        // then
        XCTAssertNil(effectiveDateInterval(from: dateInterval, for: sut._generator))
    }
    
    func test_whenDateIntervalDoesntContainAnyElement_returnsNil() {
        // given
        let possibleValues: Set<Int> = Set(Calendar.gregorianCalendar.maximumRange(of: sut.kind.component)!)
        let outOfScheduleValues = possibleValues
            .filter { !sut.onScheduleValues.contains($0) }
        let outDate = Calendar.gregorianCalendar.date(bySetting: sut.kind.component, value: outOfScheduleValues.first!, of: refDate)!
        
        // when
        dateInterval = Calendar.gregorianCalendar.dateInterval(of: sut.kind.durationComponent, for: outDate)!
        
        // then
        XCTAssertNil(effectiveDateInterval(from: dateInterval, for: sut._generator))
    }
    
    func test_whenDateIntervalStartAndEndMatchElementsStartEnd_returnsSameDateInterval()
    {
        // given
        let sorted = Array(sut.onScheduleValues)
            .sorted(by: <)
        let firstOnDate = Calendar.gregorianCalendar.date(bySetting: sut.kind.component, value: sorted.first!, of: refDate)!
        let lastOnDate = Calendar.gregorianCalendar.date(bySetting: sut.kind.component, value: sorted.last!, of: refDate)!
        let start = sut._generator(firstOnDate, .on)!.start
        let end = sut._generator(lastOnDate, .on)!.end
        
        // when
        dateInterval = DateInterval(start: start, end: end)
        
        // then
        XCTAssertEqual(effectiveDateInterval(from: dateInterval, for: sut._generator), dateInterval)
    }
    
    func test_whenDateIntervalStartDoesntIntersectElementEndMatchElementEnd_returnedDateIntervalStartMatchesElementStartFirstAfter()
    {
        // given
        let possibleValues: Set<Int> = Set(Calendar.gregorianCalendar.maximumRange(of: sut.kind.component)!)
        let outOfScheduleValues = possibleValues
            .filter { !sut.onScheduleValues.contains($0) }
        let outDate = Calendar.gregorianCalendar.date(bySetting: sut.kind.component, value: outOfScheduleValues.first!, of: refDate)!
        let firstAfter = sut._generator(outDate, .firstAfter)!
        
        // when
        dateInterval = DateInterval(start: outDate, end: firstAfter.end)
        
        // then
        XCTAssertEqual(effectiveDateInterval(from: dateInterval, for: sut._generator), firstAfter)
    }
    
    func test_whenDateIntervalStartMatchesElementStartAndEndDoesntIntersectElemend_returnedDateIntervalEndMatchesElementEndFirstBefore()
    {
        // given
        let possibleValues: Set<Int> = Set(Calendar.gregorianCalendar.maximumRange(of: sut.kind.component)!)
        let outOfScheduleValues = possibleValues
            .filter { !sut.onScheduleValues.contains($0) }
        let outDate = Calendar.gregorianCalendar.date(bySetting: sut.kind.component, value: outOfScheduleValues.first!, of: refDate)!
        let firstBefore = sut._generator(outDate, .firstBefore)!
        
        // when
        dateInterval = DateInterval(start: firstBefore.start, end: outDate)
        
        // then
        XCTAssertEqual(effectiveDateInterval(from: dateInterval, for: sut._generator), firstBefore)
    }
    
    func test_whenDateIntervalDoesntIntersectElementButContainsElements_retunedDateIntervalStartMatchesStartOfFirstContainedElementAndEndOfLastContainedElement()
    {
        // given
        let rangeOfValues = Calendar.gregorianCalendar.maximumRange(of: sut.kind.component)!
        let possibleValues: Set<Int> = Set(rangeOfValues)
        let outOfScheduleValues = Array(possibleValues).sorted()
            .filter { !sut.onScheduleValues.contains($0) }
        let earliest = outOfScheduleValues
            .first { $0 > rangeOfValues.lowerBound }!
        let later = outOfScheduleValues.reversed().first!
        let start = Calendar.gregorianCalendar.date(bySetting: sut.kind.component, value: earliest, of: refDate)!
        let end = Calendar.gregorianCalendar.date(bySetting: sut.kind.component, value: later, of: start)!
        
        let expectedStart = sut._generator(start, .firstAfter)!.start
        let expectedEnd = sut._generator(end, .firstBefore)!.end
        let expectedResult = DateInterval(start: expectedStart, end: expectedEnd)
        
        // when
        dateInterval = DateInterval(start: start, end: end)
        
        // then
        XCTAssertEqual(effectiveDateInterval(from: dateInterval, for: sut._generator), expectedResult)
    }
    
    static var allTests = [
        ("test_whenGeneratorIsEmpty_returnsNil", test_whenGeneratorIsEmpty_returnsNil),
        ("test_whenDateIntervalIntersectsSameElement_returnsNil", test_whenDateIntervalIntersectsSameElement_returnsNil),
       ("test_whenDateIntervalDoesntContainAnyElement_returnsNil", test_whenDateIntervalDoesntContainAnyElement_returnsNil),
       ("test_whenDateIntervalStartAndEndMatchElementsStartEnd_returnsSameDateInterval", test_whenDateIntervalStartAndEndMatchElementsStartEnd_returnsSameDateInterval),
        ("test_whenDateIntervalStartDoesntIntersectElementEndMatchElementEnd_returnedDateIntervalStartMatchesElementStartFirstAfter", test_whenDateIntervalStartDoesntIntersectElementEndMatchElementEnd_returnedDateIntervalStartMatchesElementStartFirstAfter),
        ("test_whenDateIntervalStartMatchesElementStartAndEndDoesntIntersectElemend_returnedDateIntervalEndMatchesElementEndFirstBefore", test_whenDateIntervalStartMatchesElementStartAndEndDoesntIntersectElemend_returnedDateIntervalEndMatchesElementEndFirstBefore),
        ("test_whenDateIntervalDoesntIntersectElementButContainsElements_retunedDateIntervalStartMatchesStartOfFirstContainedElementAndEndOfLastContainedElement", test_whenDateIntervalDoesntIntersectElementButContainsElements_retunedDateIntervalStartMatchesStartOfFirstContainedElementAndEndOfLastContainedElement),
        
    ]
}
