//
//  GregorianCommonTimetableTests
//  GregorianDaysCodableWebAPITests.swift
//  
//
//  Created by Valeriano Della Longa on 21/03/2020.
//

import XCTest
import WebAPICodingOptions
@testable import GregorianCommonTimetable

final class GregorianDaysCodableWebAPITests: XCTestCase {
    var sut: MockGregorianDays!
    
    override func setUp() {
        super.setUp()
        
        sut = MockGregorianDays(randomly: true)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    func testCodable_Encode_NoThrows() {
        // given
        let encoder = JSONEncoder()
        
        // when
        // then
        XCTAssertNoThrow(try encoder.encode(self.sut.days))
    }
    
    func testWebAPI_Encode_NoThrow() {
        // given
        let encoder = JSONEncoder()
        
        // when
        encoder.setWebAPI(version: .v1)
        
        // then
        XCTAssertNoThrow(try encoder.encode(self.sut.days))
    }
    
    func testCodable_Decode_NoThrow() {
        // given
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // when
        let data = try! encoder.encode(self.sut.days)
        
        // then
        XCTAssertNoThrow(try decoder.decode(GregorianDays.self, from: data))
    }
    
    func testWebAPI_Decode_NoThrow() {
        // given
        let encoder = JSONEncoder()
        encoder.setWebAPI(version: .v1)
        let decoder = JSONDecoder()
        decoder.setWebAPI(version: .v1)
        
        // when
        let data = try! encoder.encode(self.sut.days)
        
        // then
        XCTAssertNoThrow(try decoder.decode(GregorianDays.self, from: data))
    }
    
    func testCodable_EncodeDecode() {
        // given
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // when
        let data = try! encoder.encode(self.sut.days)
        let result = try! decoder.decode(GregorianDays.self, from: data)
        
        // then
        XCTAssertEqual(self.sut.days, result)
    }
    
    func testWebAPI_EncodeDecode() {
        // given
        let encoder = JSONEncoder()
        encoder.setWebAPI(version: .v1)
        let decoder = JSONDecoder()
        decoder.setWebAPI(version: .v1)
        
        // when
        let data = try! encoder.encode(self.sut.days)
        let result = try! decoder.decode(GregorianDays.self, from: data)
        
        // then
        XCTAssertEqual(self.sut.days, result)
    }
    
    static var allTests = [
        ("testCodable_EncodeNo_Throws", testCodable_Encode_NoThrows),
        ("testWebAPI_Encode_NoThrow", testWebAPI_Encode_NoThrow),
        ("testCodable_Decode_NoThrow", testCodable_Decode_NoThrow),
        ("testWebAPI_Decode_NoThrow", testWebAPI_Decode_NoThrow),
        ("testCodable_EncodeDecode", testCodable_EncodeDecode),
        ("testWebAPI_EncodeDecode", testWebAPI_EncodeDecode),
        
    ]
    
}
