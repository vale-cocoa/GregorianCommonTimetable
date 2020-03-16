//
//  GregorianWeekdaysCodableWebAPITests.swift
//  
//
//  Created by Valeriano Della Longa on 22/01/2020.
//

import XCTest
@testable import GregorianCommonTimetable
import WebAPICodingOptions

final class GregorianWeekdaysCodableWebAPITests: XCTestCase {
    var sut: MockGregorianWeekdays!
    
    override func setUp() {
        super.setUp()
        
        self.sut = MockGregorianWeekdays(randomly: true)
    }
    
    override func tearDown() {
        self.sut = nil
        
        super.tearDown()
    }
    
    func testCodable_Encode_NoThrows() {
        // given
        let encoder = JSONEncoder()
        
        // when
        // then
        XCTAssertNoThrow(try encoder.encode(self.sut.weekdays))
    }
    
    func testWebAPI_Encode_NoThrow() {
        // given
        let encoder = JSONEncoder()
        
        // when
        encoder.setWebAPI(version: .v1)
        
        // then
        XCTAssertNoThrow(try encoder.encode(self.sut.weekdays))
    }
    
    func testCodable_Decode_NoThrow() {
        // given
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // when
        let data = try! encoder.encode(self.sut.weekdays)
        
        // then
        XCTAssertNoThrow(try decoder.decode(GregorianWeekdays.self, from: data))
    }
    
    func testWebAPI_Decode_NoThrow() {
        // given
        let encoder = JSONEncoder()
        encoder.setWebAPI(version: .v1)
        let decoder = JSONDecoder()
        decoder.setWebAPI(version: .v1)
        
        // when
        let data = try! encoder.encode(self.sut.weekdays)
        
        // then
        XCTAssertNoThrow(try decoder.decode(GregorianWeekdays.self, from: data))
    }
    
    func testCodable_EncodeDecode() {
        // given
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // when
        let data = try! encoder.encode(self.sut.weekdays)
        let result = try! decoder.decode(GregorianWeekdays.self, from: data)
        
        // then
        XCTAssertEqual(self.sut.weekdays, result)
    }
    
    func testWebAPI_EncodeDecode() {
        // given
        let encoder = JSONEncoder()
        encoder.setWebAPI(version: .v1)
        let decoder = JSONDecoder()
        decoder.setWebAPI(version: .v1)
        
        // when
        let data = try! encoder.encode(self.sut.weekdays)
        let result = try! decoder.decode(GregorianWeekdays.self, from: data)
        
        // then
        XCTAssertEqual(self.sut.weekdays, result)
    }
    
    static var allTests = [
        ("testCodable_Encode_NoThrows", testCodable_Encode_NoThrows),
        ("testWebAPI_Encode_NoThrow", testWebAPI_Encode_NoThrow),
        ("testCodable_Decode_NoThrow", testCodable_Decode_NoThrow),
        ("testWebAPI_Decode_NoThrow", testWebAPI_Decode_NoThrow),
        ("testCodable_EncodeDecode", testCodable_EncodeDecode),
        ("testWebAPI_EncodeDecode", testWebAPI_EncodeDecode),
        
    ]
}
