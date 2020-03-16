import XCTest

import GregorianCommonTimetableTests

var tests = [XCTestCaseEntry]()
tests += GregorianCommonTimetableTests.allTests()
tests += GCTTGeneratorTests.allTests()
tests += LargestDistanceTests.allTests()
tests += ChopTests.allTests()
tests += EffectiveDateIntervalTests.allTests()
tests += ScheduleElementsTests.allTests()
tests += GCTTAsyncGeneratorTests.allTests()
tests += GregorianHoursClampedOptionSetTests.allTests()
tests += GregorianHoursCodableWebAPITests.allTests()
tests += GregorianMonthsClampedOptionSetTests.allTests()
tests += GregorianMonthsCodableWebAPITests.allTests()
tests += GregorianWeekdaysClampedOptionSetTests.allTests()
tests += GregorianWeekdaysCodableWebAPITests.allTests()
XCTMain(tests)
