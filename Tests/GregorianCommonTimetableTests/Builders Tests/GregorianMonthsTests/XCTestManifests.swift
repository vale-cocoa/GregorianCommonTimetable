import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(GregorianMonthsClampedOptionSetTests.allTests),
        testCase(GregorianMonthsCodableWebAPITests.allTests),
        testCase(GregorianMonthsSchedulableTests.allTests),
        
    ]
}
#endif
