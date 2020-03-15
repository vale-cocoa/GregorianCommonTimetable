import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(GregorianCommonTimetableTests.allTests),
        testCase(GCTTGeneratorTests.allTests),
        testCase(LargestDistanceTests.allTests),
        testCase(ChopTests.allTests),
        testCase(EffectiveDateIntervalTests.allTests),
        testCase(ScheduleElementsTests.allTests),
        testCase(GCTTAsyncGeneratorTests.allTests),
        
    ]
}
#endif
