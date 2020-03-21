import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(GregorianCommonTimetableTests.allTests),
        testCase(GCTTGeneratorTests.allTests),
        testCase(ShiftValueTests.allTests),
        testCase(ShiftDaysValueTests.allTests),
        testCase(DaysShiftToAdjacentMonthTests.allTests),
        testCase(LargestDistanceTests.allTests),
        testCase(ChopTests.allTests),
        testCase(EffectiveDateIntervalTests.allTests),
        testCase(ScheduleElementsTests.allTests),
        testCase(GCTTAsyncGeneratorTests.allTests),
        testCase(GregorianHoursClampedOptionSetTests.allTests),
        testCase(GregorianHoursCodableWebAPITests.allTests),
        testCase(GregorianMonthsClampedOptionSetTests.allTests),
        testCase(GregorianMonthsCodableWebAPITests.allTests),
        testCase(GregorianWeekdaysClampedOptionSetTests.allTests),
        testCase(GregorianWeekdaysCodableWebAPITests.allTests),
        testCase(GregorianDaysClampedOptionSetTests.allTests),
        testCase(GregorianDaysCodableWebAPITests.allTests),
        
    ]
}
#endif
