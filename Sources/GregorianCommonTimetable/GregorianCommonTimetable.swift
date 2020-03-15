//
//  GregorianCommonTimetable
//  GregorianCommonTimetable.swift
//
//  Created by Valeriano Della Longa on 12/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import Schedule
import VDLCalendarUtilities
import VDLGCDHelpers

/// A `Schedule` concrete type which represents a common timetable based on gregorian
///  calendar time unit.
public struct GregorianCommonTimetable {
    /// An enum used to differentiate between each kind of representable timetable.
    public enum Kind: CaseIterable {
        /// Represents a year's months timetable
        case monthlyBased
        
        /// Represents a weekdays timetable
        case weekdayBased
        
        /// Represents a timetable based on hours of the day
        case hourlyBased
    
        /// The `Calendar.Component` used for the schedule.
        public var component: Calendar.Component {
            switch self {
            case .monthlyBased:
                return .month
            case .weekdayBased:
                return .weekday
            case .hourlyBased:
                return .hour
            }
        }
        
        /// The `Calendar.Component` representing the duration of
        /// the `Schedule.Elements` for the schedule.
        public var durationComponent: Calendar.Component {
            if case .weekdayBased = self { return .day }
            
            return self.component
        }
        
        /// The range of values the schedule could contain.
        ///
        /// For example a `weekdayBased` kind could contain values in the range `1...7`,
        /// where each value of the range represents a weekday value.
        /// - See also `Calendar.Component` and `DateComponents`.
        public var rangeOfScheduleValues: Range<Int> {
            
            return Calendar.gregorianCalendar.maximumRange(of: self.component)!
        }
        
        var componentsForDistanceCalculation: Set<Calendar.Component> {
            switch self {
            case .monthlyBased:
                return [.year]
            case .weekdayBased:
                return [.year, .month, .weekOfYear]
            case .hourlyBased:
                return [.year, .month, .weekOfYear, .day]
            }
        }
        
    }
    
    /// Errors thrown by this type
    public enum Error: Swift.Error
    {
        /// Thrown when attepting to initialize giving a schedule value out of range
        case scheduleValueOutOfRange
       
        /// Returned as `.failure` associated value of a the result by a
        ///  `Schedule.AsuncGenerator` for an instance which lags on calculating
        ///  concurrently the elements.
        case timeout
    }
    
    /// The kind of this `GregorianCommonTimetable` instance.
    public let kind: Kind
    
    /// The values of this instance schedule for its `kind` value.
    ///
    /// - See also: `Kind`.
    public let onScheduleValues: Set<Int>
    
    let _generator: Schedule.Generator
    
    let _asyncGenerator: Schedule.AsyncGenerator
    
    /// Returns a new instance of `GregorianCommonTimetable` initialized with the given
    /// parameters —whenever they are valid.
    ///
    /// - Parameter kind: The `Kind` of schedule.
    /// - Parameter onSchedule: A `Set<Int>` containig the values of the schedule.
    /// - Returns: A `GregorianCommonTimetable` instance of the given `Kind`
    ///  which produces `Schedule.Elements` representing the given schedule values.
    /// - Throws: `Error.scheduleValueOutOfRange` if given `onSchedule`
    ///  contains one or more values out of range in respect of the given `kind`.
    public init(kind: Kind, onSchedule values: Set<Int>) throws
    {
        self._generator = try Self.scheduleGenerator(kind: kind, for: values)
        self._asyncGenerator = try Self.scheduleAsyncGenerator(kind: kind, for: values)
        self.kind = kind
        self.onScheduleValues = values
    }
    
    // MARK: - Internal static methods
    static func scheduleGenerator(kind: Kind,
        for scheduledValues: Set<Int>
    ) throws
        -> Schedule.Generator
    {
        guard
            scheduledValues.isSubset(of: Set(kind.rangeOfScheduleValues))
            else { throw Error.scheduleValueOutOfRange }
        
        guard !scheduledValues.isEmpty else { return emptyGenerator }
        
        let range = kind.rangeOfScheduleValues
        let duration = kind.durationComponent
        let match = kind.component
        
        return { [range, duration, match, scheduledValues] date, direction in
            let dateCompValue = Calendar.gregorianCalendar.component(match, from: date)
            let increment: Int!
            switch direction {
            case .on:
                return scheduledValues.contains(dateCompValue) ? Calendar.gregorianCalendar.dateInterval(of: duration, for: date) : nil
            case .firstAfter:
                increment = 1
            case .firstBefore:
                increment = -1
            }
            
            var shift = increment!
            while shift <= range.count {
                let incremented = dateCompValue + shift
                let candidate: Int!
                if increment == 1 && incremented >= range.upperBound
                {
                    candidate = incremented - range.count
                } else if increment == -1 && incremented < range.lowerBound
                {
                    candidate = incremented + range.count
                } else {
                    candidate = incremented
                }
                
                if scheduledValues.contains(candidate) {
                    guard
                        let onDate = Calendar.gregorianCalendar.date(byAdding: duration, value: shift, to: date)
                        else { return nil }
                    
                    return Calendar.gregorianCalendar.dateInterval(of: duration, for: onDate)
                }
                
                shift += increment
            }
            
            return nil
        }
    }
    
    static func scheduleAsyncGenerator(
        kind: Kind,
        for scheduledValues: Set<Int>
    ) throws
        -> Schedule.AsyncGenerator
    {
        let scheduleGenerator = try Self.scheduleGenerator(kind: kind, for: scheduledValues)
        
        guard !isEmptyGenerator(scheduleGenerator)
            else {
                
                return { dateInterval, queue, completion in
                    DispatchQueue.global(qos: .userInitiated).async {
                        dispatchResultCompletion(result: .success([]), queue: queue, completion: completion)
                    }
                }
        }
        
        return { dateInterval, queue, completion in
            DispatchQueue.global(qos: .userInitiated).async {
                var result: Result<[DateInterval], Swift.Error>!
                do {
                    let elements = try scheduleElements(for: scheduleGenerator, of: kind, in: dateInterval)
                    result = .success(elements)
                } catch {
                    result = .failure(error)
                }
                dispatchResultCompletion(result: result, queue: queue, completion: completion)
            }
        }
    }
    
}
