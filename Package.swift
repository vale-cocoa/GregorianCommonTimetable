// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GregorianCommonTimetable",
    platforms: [.iOS(.v10), .macOS(.v10_15), .watchOS(.v3), .tvOS(.v10)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "GregorianCommonTimetable",
            targets: ["GregorianCommonTimetable"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/vale-cocoa/Schedule.git", from: "1.0.4"),
        .package(url: "https://github.com/vale-cocoa/VDLCalendarUtilities.git", from: "2.2.0"),
        .package(url: "https://github.com/vale-cocoa/VDLGCDHelpers.git", from: "1.0.2"),
        .package(url: "https://github.com/vale-cocoa/ClampedOptionSet.git", from: "1.0.1"),
        .package(url: "https://github.com/vale-cocoa/WebAPICodingOptions.git", from: "1.2.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "GregorianCommonTimetable",
            dependencies: ["Schedule", "VDLCalendarUtilities", "VDLGCDHelpers", "ClampedOptionSet", "WebAPICodingOptions"]),
        .testTarget(
            name: "GregorianCommonTimetableTests",
            dependencies: ["GregorianCommonTimetable"]),
    ]
)
