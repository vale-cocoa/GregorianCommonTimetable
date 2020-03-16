import XCTest
@testable import GregorianCommonTimetable

final class GregorianHoursClampedOptionSetTests: XCTestCase {
    func testMaxRawValue() {
        // given
        let expectedResult = GregorianHoursOfDay.everyHour.rawValue
        
        // when
        // then
        XCTAssertEqual(expectedResult, GregorianHoursOfDay.maxRawValue)
        
    }
    
    func testAllBaseValidMemebersAsStrings() {
        // given
        let expectedResult = [
            "12:00am", "01:00am", "02:00am", "03:00am",
            "04:00am", "05:00am", "06:00am", "07:00am",
            "08:00am", "09:00am", "10:00am", "11:00am",
            "12:00pm", "01:00pm", "02:00pm", "03:00pm",
            "04:00pm", "05:00pm", "06:00pm", "07:00pm",
            "08:00pm", "09:00pm", "10:00pm", "11:00pm"
        ]
        
        // when
        // then
        XCTAssertEqual(expectedResult, GregorianHoursOfDay.allBaseValidMembersAsStrings)
    }
    
    func testValidRawValueForString_returnsNil() {
        // given
        let invalidStrings = [" ", "25", "A phrase.", "0000", "1234", "A", "#", "24:00am", "24:00"]
        
        // when
        for invalidString in invalidStrings {
            // then
            XCTAssertNil(GregorianHoursOfDay.validRawValueForString(invalidString), "\(invalidString) returns a valid rawValue")
        }
    }
    
    func testValidRawValueForString_returnsValidValues() {
        // given
        let inputStrings = [
            "12:00am", "01:00am", "02:00am", "03:00am",
            "04:00am", "05:00am", "06:00am", "07:00am",
            "08:00am", "09:00am", "10:00am", "11:00am",
            "12:00pm", "01:00pm", "02:00pm", "03:00pm",
            "04:00pm", "05:00pm", "06:00pm", "07:00pm",
            "08:00pm", "09:00pm", "10:00pm", "11:00pm"
        ]
        let uppercased = inputStrings.map { $0.uppercased() }
        let expectedResultHours: [GregorianHoursOfDay] = [
            .am12, .am1, .am2, .am3,
            .am4, .am5, .am6, .am7,
            .am8, .am9, .am10, .am11,
            .pm12, .pm1, .pm2, .pm3,
            .pm4, .pm5, .pm6, .pm7,
            .pm8, .pm9, .pm10, .pm11
        ]
        let expectedResult = expectedResultHours.map { $0.rawValue }
        
        // when
        let resultForValid = inputStrings.compactMap { GregorianHoursOfDay.validRawValueForString($0) }
        let resultForUpperCased = uppercased.compactMap { GregorianHoursOfDay.validRawValueForString($0) }
        
        // then
        XCTAssertEqual(expectedResult, resultForValid)
        XCTAssertEqual(expectedResult, resultForUpperCased)
    }
    
    func testInitFromString_Throws() {
        // given
        let invalidString = "invalid string"
        
        // when
        // then
        XCTAssertThrowsError(try GregorianHoursOfDay(string: invalidString))
    }
    
    func testInitFromString_NoThrows() {
        // given
        let validString = "12:00am"
        
        // when
        // then
        XCTAssertNoThrow(try GregorianHoursOfDay(string: validString))
    }
    
    func testInitFromStrings_Throws() {
        // given
        let invalidStrings = [" ", "25", "A phrase.", "0000", "1234", "A", "#", "24:00am", "24:00"]
        
        // when
        // then
        XCTAssertThrowsError(try GregorianHoursOfDay(strings: invalidStrings))
    }
    
    func testInitFromStrings_NoThrows() {
        // given
        let validStrings = [
            "12:00am", "01:00am", "02:00am", "03:00am",
            "04:00am", "05:00am", "06:00am", "07:00am",
            "08:00am", "09:00am", "10:00am", "11:00am",
            "12:00pm", "01:00pm", "02:00pm", "03:00pm",
            "04:00pm", "05:00pm", "06:00pm", "07:00pm",
            "08:00pm", "09:00pm", "10:00pm", "11:00pm"
        ]
        
        // when
        // then
        XCTAssertNoThrow(try GregorianHoursOfDay(strings: validStrings))
    }
    
    func testValidRawValueFromDate() {
        // given
        let dc = DateComponents(year: 2001, month: 1, day: 1, hour: 0, minute: 1, second: 1)
        let startDate = Calendar.gregorianCalendar.date(from: dc)!
        let expectedResult = [
            GregorianHoursOfDay.am12.rawValue,
            GregorianHoursOfDay.am1.rawValue,
            GregorianHoursOfDay.am2.rawValue,
            GregorianHoursOfDay.am3.rawValue,
            GregorianHoursOfDay.am4.rawValue,
            GregorianHoursOfDay.am5.rawValue,
            GregorianHoursOfDay.am6.rawValue,
            GregorianHoursOfDay.am7.rawValue,
            GregorianHoursOfDay.am8.rawValue,
            GregorianHoursOfDay.am9.rawValue,
            GregorianHoursOfDay.am10.rawValue,
            GregorianHoursOfDay.am11.rawValue,
            GregorianHoursOfDay.pm12.rawValue,
            GregorianHoursOfDay.pm1.rawValue,
            GregorianHoursOfDay.pm2.rawValue,
            GregorianHoursOfDay.pm3.rawValue,
            GregorianHoursOfDay.pm4.rawValue,
            GregorianHoursOfDay.pm5.rawValue,
            GregorianHoursOfDay.pm6.rawValue,
            GregorianHoursOfDay.pm7.rawValue,
            GregorianHoursOfDay.pm8.rawValue,
            GregorianHoursOfDay.pm9.rawValue,
            GregorianHoursOfDay.pm10.rawValue,
            GregorianHoursOfDay.pm11.rawValue
        ]
        
        // when
        let result: [UInt] = (0..<24).map { hour in
            let date = Calendar.gregorianCalendar.date(byAdding: .hour, value: hour, to: startDate)!
            
            return GregorianHoursOfDay(from: date).rawValue
        }
        
        // then
        XCTAssertEqual(expectedResult, result)
    }
    
    func testInitFromDate() {
        // given
        let dc = DateComponents(year: 2001, month: 1, day: 1, hour: 0, minute: 1, second: 1)
        let startDate = Calendar.gregorianCalendar.date(from: dc)!
        let randomHour = Int.random(in: 0..<24)
        let initDate = Calendar.gregorianCalendar.date(byAdding: .hour, value: randomHour, to: startDate)!
        let expectedResult = GregorianHoursOfDay(rawValue: 1 << randomHour)
        
        // when
        let result = GregorianHoursOfDay(from: initDate)
        
        // then
        XCTAssertEqual(expectedResult, result)
    }
    
    func testInitFromDates() {
        // given
        let dc = DateComponents(year: 2001, month: 1, day: 1, hour: 0, minute: 1, second: 1)
        let startDate = Calendar.gregorianCalendar.date(from: dc)!
        let numberOfDates = Int.random(in: 1...24)
        var dates = [Date]()
        var expectedResult = GregorianHoursOfDay()
        for _ in 0..<numberOfDates {
            let randomHour = Int.random(in: 0...23)
            let randomDate = Calendar.gregorianCalendar.date(byAdding: .hour, value: randomHour, to: startDate)!
            dates.append(randomDate)
            let iterResult = GregorianHoursOfDay(rawValue: 1 << randomHour)
            expectedResult.insert(iterResult)
        }
        
        // when
        let result = GregorianHoursOfDay(from: dates)
        
        // then
        XCTAssertEqual(expectedResult, result)
    }
    
    func testContains() {
        // given
        let sut = MockGregorianHours.init(randomly: true)
        let dc = DateComponents(year: 2001, month: 1, day: 1, hour: 0, minute: 1, second: 1)
        let startDate = Calendar.gregorianCalendar.date(from: dc)!
        let dates: [Date] = (0..<24).map {
            return Calendar.gregorianCalendar.date(byAdding: .hour, value: $0, to: startDate)!
        }
        let expectedResult = sut.containedHours
        
        // when
        let result: [Bool] = dates.map { sut.hours.contains(date: $0) }
        
        // then
        XCTAssertEqual(expectedResult, result)
    }
    
    static var allTests = [
        ("testMaxRawValue", testMaxRawValue),
        ("testValidRawValueForString_returnsNil", testValidRawValueForString_returnsNil),
        ("testValidRawValueForString_returnsValidValues", testValidRawValueForString_returnsValidValues),
        ("testInitFromString_Throws", testInitFromString_Throws),
        ("testInitFromString_NoThrows", testInitFromString_NoThrows),
        ("testInitFromStrings_Throws", testInitFromStrings_Throws),
        ("testInitFromStrings_NoThrows", testInitFromStrings_NoThrows),
        ("testValidRawValueFromDate", testValidRawValueFromDate),
        ("testInitFromDate", testInitFromDate),
        ("testInitFromDates", testInitFromDates),
        ("testContains", testContains),
    ]
}
