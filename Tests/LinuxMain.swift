import XCTest

import GregorianCommonTimetableTests

var tests = [XCTestCaseEntry]()
tests += GregorianCommonTimetableTests.allTests()
tests += GCTTGeneratorTests.allTests()
tests += ShiftValueTests.allTests()
tests += ShiftDaysValueTests.allTests()
tests += DaysShiftToAdjacentMonthTests.allTests()
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
tests += GregorianDaysClampedOptionSetTests.allTests()
tests += GregorianDaysWebAPITests.allTests()

XCTMain(tests)
