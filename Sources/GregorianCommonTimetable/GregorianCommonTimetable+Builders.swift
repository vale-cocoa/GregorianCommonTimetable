//
//  GregorianCommonTimetable+Builders.swift
//  GregorianCommonTimetable
//
//  Created by Valeriano Della Longa on 16/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation

extension GregorianCommonTimetable {
    /// Safely initialize via `GregorianHoursOfDay` instance.
    ///
    /// - Parameter _: An instance of `GregorianHoursOfDay` type.
    /// - Returns: An instance of `GregorianCommonTimetable` initialized
    ///  with a `kind` value of `.hourlyBased`.
    public init(_ builder: GregorianHoursOfDay) {
        self = try! Self(kind: .hourlyBased, onSchedule: builder.onScheduleValues)
    }
    
    /// Safely initialize via `GregorianWeekdays` instance.
    ///
    /// - Parameter _: An instance of `GregorianWeekdays` type.
    /// - Returns: An instance of `GregorianCommonTimetable` initialized
    ///  with a `kind` value of `.weekdayBased`.
    public init(_ builder: GregorianWeekdays) {
        self = try! Self(kind: .weekdayBased, onSchedule: builder.onScheduleValues)
    }
    
    /// Safely initialize via `GregorianDays` instance.
    ///
    /// - Parameter _: An instance of `GregorianDays` type.
    /// - Returns: An instance of `GregorianCommonTimetable` initialized
    ///  with a `kind` value of `.dailyBased`.
    public init(_ builder: GregorianDays) {
        self = try! Self(kind: .dailyBased, onSchedule: builder.onScheduleValues)
    }
    
    /// Safely initialize via `GregorianMonths` instance.
    ///
    /// - Parameter _: An instance of `GregorianMonths` type.
    /// - Returns: An instance of `GregorianCommonTimetable` initialized
    ///  with a `kind` value of `.monthlyBased`.
    public init(_ builder: GregorianMonths) {
        self = try! Self(kind: .monthlyBased, onSchedule: builder.onScheduleValues)
    }
    
    var rawValueOfBuilder: UInt {
        guard !onScheduleValues.isEmpty else { return 0 }
        
        let adjustement = .hourlyBased == kind ? 0 : -1
        
        return onScheduleValues
            .reduce(UInt(0)) { partial, componentValue in
                let shift = componentValue + adjustement
                let rawValue = UInt(1 << shift)
                return partial | rawValue
        }
    }
    
    var onScheduleAsStrings: [String] {
        guard !onScheduleValues.isEmpty else { return [] }
        
        switch self.kind {
        case .hourlyBased:
            let hours = GregorianHoursOfDay(rawValue: rawValueOfBuilder)
            return hours.baseValidMembersAsStrings
        case .dailyBased:
            let days = GregorianDays(rawValue: rawValueOfBuilder)
            return days.baseValidMembersAsStrings
        case .weekdayBased:
            let weekdays = GregorianWeekdays(rawValue: rawValueOfBuilder)
            return weekdays.baseValidMembersAsStrings
        case .monthlyBased:
            let months = GregorianMonths(rawValue: rawValueOfBuilder)
            return months.baseValidMembersAsStrings
        }
    }
    
}

extension GregorianCommonTimetable {
    /// An enum where each case represents a builder Type for
    ///  `GregorianCommonTimetable`, associated to a value of that Type.
    public enum Builder {
        case gregorianHoursOfDay(GregorianHoursOfDay)
        case gregorianWeekdays(GregorianWeekdays)
        case gregorianDays(GregorianDays)
        case gregorianMonths(GregorianMonths)
    }
    
    /// The `Builder` representing this instance.
    public var builder: Builder {
        switch kind {
        case .monthlyBased:
            return .gregorianMonths(GregorianMonths(rawValue: rawValueOfBuilder))
        case .dailyBased:
            return .gregorianDays(GregorianDays(rawValue: rawValueOfBuilder))
        case .weekdayBased:
            return .gregorianWeekdays(GregorianWeekdays(rawValue: rawValueOfBuilder))
        case .hourlyBased:
            return .gregorianHoursOfDay(GregorianHoursOfDay(rawValue: rawValueOfBuilder))
        }
    }
    
    /// Safely creates a new instance via a `Builder` instance.
    ///
    /// - parameter _: The Builder instance to use.
    /// - Returns: A new `GregorianCommonTimetable` instance initialized
    ///  with the values derived from the given `Builder` instance.
    public init(_ builder: Builder)
    {
        switch builder {
        case .gregorianMonths(let months):
            self.init(months)
        case .gregorianWeekdays(let weekdays):
            self.init(weekdays)
        case .gregorianDays(let days):
            self.init(days)
        case .gregorianHoursOfDay(let hours):
            self.init(hours)
        }
    }
    
}
