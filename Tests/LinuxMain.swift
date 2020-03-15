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
XCTMain(tests)
