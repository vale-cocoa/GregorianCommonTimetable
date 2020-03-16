import XCTest
@testable import GregorianCommonTimetable
import WebAPICodingOptions

final class GregorianHoursCodableWebAPITests: XCTestCase {
    var sut: MockGregorianHours!
    
    override func setUp() {
        super.setUp()
        
        self.sut = MockGregorianHours(randomly: true)
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
        XCTAssertNoThrow(try encoder.encode(self.sut.hours))
    }
    
    func testWebAPI_Encode_NoThrow() {
        // given
        let encoder = JSONEncoder()
        
        // when
        encoder.setWebAPI(version: .v1)
        
        // then
        XCTAssertNoThrow(try encoder.encode(self.sut.hours))
    }
    
    func testCodable_Decode_NoThrow() {
        // given
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // when
        let data = try! encoder.encode(self.sut.hours)
        
        // then
        XCTAssertNoThrow(try decoder.decode(GregorianHoursOfDay.self, from: data))
    }
    
    func testWebAPI_Decode_NoThrow() {
        // given
        let encoder = JSONEncoder()
        encoder.setWebAPI(version: .v1)
        let decoder = JSONDecoder()
        decoder.setWebAPI(version: .v1)
        
        // when
        let data = try! encoder.encode(self.sut.hours)
        
        // then
        XCTAssertNoThrow(try decoder.decode(GregorianHoursOfDay.self, from: data))
    }
    
    func testCodable_EncodeDecode() {
        // given
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // when
        let data = try! encoder.encode(self.sut.hours)
        let result = try! decoder.decode(GregorianHoursOfDay.self, from: data)
        
        // then
        XCTAssertEqual(self.sut.hours, result)
    }
    
    func testWebAPI_EncodeDecode() {
        // given
        let encoder = JSONEncoder()
        encoder.setWebAPI(version: .v1)
        let decoder = JSONDecoder()
        decoder.setWebAPI(version: .v1)
        
        // when
        let data = try! encoder.encode(self.sut.hours)
        let result = try! decoder.decode(GregorianHoursOfDay.self, from: data)
        
        // then
        XCTAssertEqual(self.sut.hours, result)
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
