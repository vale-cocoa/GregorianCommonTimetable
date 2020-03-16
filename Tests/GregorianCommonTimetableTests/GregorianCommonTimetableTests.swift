//
//  GregorianCommonTimetableTests
//  GregorianCommonTimetableTests.swift
//
//  Created by Valeriano Della Longa on 13/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//
import XCTest
@testable import GregorianCommonTimetable
import Schedule

final class GregorianCommonTimetableTests: XCTestCase {
    var sut: GregorianCommonTimetable!
    var kind: GregorianCommonTimetable.Kind!
    var onScheduleValues: Set<Int>!
    
    // MARK: - Tests lifecycle
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        sut = nil
        kind = nil
        onScheduleValues = nil
    }
    
    // MARK: - Given
    func givenOutOfRangeOnScheduleValues() -> [GregorianCommonTimetable.Kind : Set<Int>]
    {
        return GregorianCommonTimetable.Kind.allCases.reduce([GregorianCommonTimetable.Kind : Set<Int>]()) { partial, kind in
            let outOfRangeValues: Set<Int> = [kind.rangeOfScheduleValues.upperBound, kind.rangeOfScheduleValues.lowerBound - 1]
            var newResult = partial
            newResult[kind] = outOfRangeValues
            return newResult
        }
    }
    
    func givenInRangeOnScheduleValues() -> [GregorianCommonTimetable.Kind : Set<Int>]
    {
        return GregorianCommonTimetable.Kind.allCases.reduce([GregorianCommonTimetable.Kind : Set<Int>]()) { partial, kind in
            var newResult = partial
            newResult[kind] = Set(kind.rangeOfScheduleValues)
            return newResult
        }
    }
    
    func givenEmptyOnScheduleValues() -> [GregorianCommonTimetable.Kind : Set<Int>]
    {
        return GregorianCommonTimetable.Kind.allCases.reduce([GregorianCommonTimetable.Kind : Set<Int>]()) { partial, kind in
            var newResult = partial
            newResult[kind] = []
            return newResult
        }
    }
    
    // MARK: - When
    func when_scheduleGeneratorThrows_cases() -> [() -> Void]
    {
        givenOutOfRangeOnScheduleValues()
            .map { given in
                
                return {
                    self.kind = given.key
                    self.onScheduleValues = given.value
                }
        }
    }
    
    func when_scheduleGeneratorDoesntThrow_cases() -> [() -> Void]
    {
        let inRangeCases: [() -> Void] = givenInRangeOnScheduleValues()
            .map { given in
                
                return {
                    self.kind = given.key
                    self.onScheduleValues = given.value
                }
        }
        
        let emptyCases: [() -> Void] = givenEmptyOnScheduleValues()
            .map { given in
            
                return {
                    self.kind = given.key
                    self.onScheduleValues = given.value
                }
                
        }
        
        return inRangeCases + emptyCases
    }
    
    func when_initDoesntThrow_cases() -> [() -> Void]
    {
        when_scheduleGeneratorDoesntThrow_cases()
            .map { when in
                
                return {
                    when()
                    self.sut = try! GregorianCommonTimetable(kind: self.kind, onSchedule: self.onScheduleValues)
                }
        }
    }
    
    // MARK: - Tests
    
    // MARK: - scheduleGenerator(kind:for:) tests
    func test_scheduleGenerator_whenForValuesOutOfComponentRange_throws()
    {
        // given
        for kind in GregorianCommonTimetable.Kind.allCases
        {
            let range = kind.rangeOfScheduleValues
            
            // when
            let values:Set<Int> = [range.upperBound, range.lowerBound - 1]
            
            // then
            XCTAssertThrowsError(try GregorianCommonTimetable.scheduleGenerator(kind: kind, for: values))
        }
    }
    
    func test_scheduleGenerator_whenForValuesEmpty_doesntThrows()
    {
        // given
        for kind in GregorianCommonTimetable.Kind.allCases
        {
            // when
            // then
            XCTAssertNoThrow(try GregorianCommonTimetable.scheduleGenerator(kind: kind, for: []))
        }
    }
    
    func test_scheduleGenerator_whenForValuesEmpty_returnsEmptyGenerator()
    {
        // given
        for kind in GregorianCommonTimetable.Kind.allCases
        {
            // when
            // guaranted by test_scheduleGenerator_whenForValuesEmpty_doesntThrows
            let generator = try! GregorianCommonTimetable.scheduleGenerator(kind: kind, for: [])
            // then
            XCTAssertTrue(isEmptyGenerator(generator))
        }
    }
    
    func test_scheduleGenerator_whenForValuesAreInComponentRange_doesntThrow()
    {
        // given
        for kind in GregorianCommonTimetable.Kind.allCases
        {
            let range = kind.rangeOfScheduleValues
            
            // when
            let values = Set(range)
            
            // then
            XCTAssertNoThrow(try GregorianCommonTimetable.scheduleGenerator(kind: kind, for: values))
        }
    }
    
    func test_scheduleGenerator_whenForValuesAreInComponentRange_returnsNotEmptyGenerator()
    {
        // given
        for kind in GregorianCommonTimetable.Kind.allCases
        {
            let range = kind.rangeOfScheduleValues
            
            // when
            let values = Set(range)
            // guaranted by test_scheduleGenerator_whenForValuesAreInComponentRange_doesntThrow
            let generator = try! GregorianCommonTimetable.scheduleGenerator(kind: kind, for: values)
            // then
            XCTAssertFalse(isEmptyGenerator(generator))
        }
    }
    
    // MARK: - scheduleAsyncGenerator(kind:for:)
    func test_scheduleAsyncGenerator_whenScheduleGeneratorThrows_throws()
    {
        // given
        for when in when_scheduleGeneratorThrows_cases()
        {
            // when
            when()
            
            // then
            XCTAssertThrowsError(try GregorianCommonTimetable.scheduleAsyncGenerator(kind: kind, for: onScheduleValues))
        }
    }
    
    func test_scheduleAsyncGenerator_whenScheduleGeneratorDoesntThrow_doesntThrow()
    {
        // given
        for when in when_scheduleGeneratorDoesntThrow_cases()
        {
            // when
            when()
            
            // then
            XCTAssertNoThrow(try GregorianCommonTimetable.scheduleAsyncGenerator(kind: kind, for: onScheduleValues))
        }
    }
    
    // MARK: - init(kind:onSchedule:) tests
    func test_init_whenScheduleGeneratorThrows_throws()
    {
        // given
        for when in when_scheduleGeneratorThrows_cases()
        {
            // when
            when()
            
            // then
            XCTAssertThrowsError(try GregorianCommonTimetable(kind: kind, onSchedule: onScheduleValues))
        }
    }
    
    func test_init_whenScheduleGeneratorDoesntThrow_doesntThrow()
    {
        // given
        for when in when_scheduleGeneratorDoesntThrow_cases()
        {
            // when
            when()
            
            // then
            XCTAssertNoThrow(try GregorianCommonTimetable(kind: kind, onSchedule: onScheduleValues))
        }
    }
    
    func test_init_whenDoesntThrow_setsProperties()
    {
        // given
        for when in when_initDoesntThrow_cases()
        {
            // when
            when()
            
            // then
            XCTAssertEqual(sut.kind, kind)
            XCTAssertEqual(sut.onScheduleValues, onScheduleValues)
            XCTAssertNotNil(sut._generator)
            XCTAssertEqual(sut.onScheduleValues.isEmpty, isEmptyGenerator(sut._generator))
            XCTAssertNotNil(sut._asyncGenerator)
        }
    }
    
    func test_codableConformance()
    {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // given
        for expectedKind in GregorianCommonTimetable.Kind.allCases.shuffled()
        {
            onScheduleValues = Set(expectedKind.rangeOfScheduleValues)
            sut = try! GregorianCommonTimetable(kind: expectedKind, onSchedule: onScheduleValues)
            do {
                let data = try encoder.encode(sut)
                let result = try decoder.decode(GregorianCommonTimetable.self, from: data)
                XCTAssertEqual(result.kind, expectedKind)
                XCTAssertEqual(result.onScheduleValues, onScheduleValues)
            } catch {
                XCTFail("Not conforming to Codable. Error: \(error)")
            }
        }
    }
    
    static var allTests = [
        ("test_scheduleGenerator_whenForValuesOutOfComponentRange_throws", test_scheduleGenerator_whenForValuesOutOfComponentRange_throws),
        ("test_scheduleGenerator_whenForValuesEmpty_doesntThrows", test_scheduleGenerator_whenForValuesEmpty_doesntThrows),
        ("test_scheduleGenerator_whenForValuesEmpty_returnsEmptyGenerator", test_scheduleGenerator_whenForValuesEmpty_returnsEmptyGenerator),
        ("test_scheduleGenerator_whenForValuesAreInComponentRange_doesntThrow", test_scheduleGenerator_whenForValuesAreInComponentRange_doesntThrow),
        ("test_scheduleGenerator_whenForValuesAreInComponentRange_returnsNotEmptyGenerator", test_scheduleGenerator_whenForValuesAreInComponentRange_returnsNotEmptyGenerator),
        ("test_scheduleAsyncGenerator_whenScheduleGeneratorThrows_throws", test_scheduleAsyncGenerator_whenScheduleGeneratorThrows_throws),
        ("test_ascheduleAsyncGenerator_whenScheduleGeneratorDoesntThrow_doesntThrow", test_scheduleAsyncGenerator_whenScheduleGeneratorDoesntThrow_doesntThrow),
        ("test_init_whenScheduleGeneratorThrows_throws", test_init_whenScheduleGeneratorThrows_throws),
        ("test_init_whenScheduleGeneratorDoesntThrow_doesntThrow", test_init_whenScheduleGeneratorDoesntThrow_doesntThrow),
        ("test_init_whenDoesntThrow_setsProperties", test_init_whenDoesntThrow_setsProperties),
        ("test_codableConformance", test_codableConformance),
        
    ]
}
