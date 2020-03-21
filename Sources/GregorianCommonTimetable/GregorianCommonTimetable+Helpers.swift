//
//  GregorianCommonTimetable
//  GregorianCommonTimetable+Helpers.swift
//
//  Created by Valeriano Della Longa on 13/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import Schedule
import VDLCalendarUtilities

// MARK: - Helpers for scheduleGenerator
func shiftValue(for date: Date, in schedule: Set<Int>, of kind: GregorianCommonTimetable.Kind, to criteria: CalendarCalculationMatchingDateDirection) -> Int?
{
    let validRange = kind.rangeOfScheduleValues
    guard
        !schedule.isEmpty,
        schedule.isSubset(of: validRange)
        else { return nil }
    
    if kind == .dailyBased {
        
        return shiftDaysValue(from: date, in: schedule, to: criteria)
    } else {
        let dayValue = Calendar.gregorianCalendar.component(kind.component, from: date)
        let increment: Int!
        switch criteria {
        case .on:
            
            return schedule.contains(dayValue) ? 0 : nil
        case .firstBefore:
            increment = -1
        case .firstAfter:
            increment = 1
        }
        var shift = increment!
        while abs(shift) <= validRange.count {
            let incremented = dayValue + shift
            let candidate: Int!
            if
                increment == 1 && incremented >= validRange.upperBound
            {
                candidate = incremented - validRange.count
            } else if
                increment == -1 && incremented < validRange.lowerBound
            {
                candidate = incremented + validRange.count
            } else {
                candidate = incremented
            }
            
            if schedule.contains(candidate) {
                
                return shift
            }
            shift += increment
        }
    }
    
    return nil
}

func shiftDaysValue(from date: Date, in schedule: Set<Int>, to criteria: CalendarCalculationMatchingDateDirection) -> Int?
{
    guard
        !schedule.isEmpty,
        schedule.isSubset(of: GregorianCommonTimetable.Kind.dailyBased.rangeOfScheduleValues),
        let rangeOfDays = Calendar.gregorianCalendar.range(of: .day, in: .month, for: date)
        else { return nil }
    
    let includeLastMonthDay = schedule
        .contains(31)
    let dayValue = Calendar.gregorianCalendar.component(.day, from: date)
    switch criteria {
    case .on:
        if schedule.contains(dayValue) || (includeLastMonthDay && dayValue == rangeOfDays.last!) { return 0 }
        
    case .firstBefore:
        let sorted = Array(schedule).sorted(by: <)
        if
            let valueBefore = sorted.last(where: { $0 < dayValue })
        {
            // We've got a value right before on this same month
            return valueBefore - dayValue
        }
        if includeLastMonthDay {
            // we haven't gotten a schedule value in this month
            // right before, but we can use the last day of the previous
            // month
            
            return -dayValue
        }
        // we'll have to look up on previous months:
        return daysShiftToAdjacentMonth(from: date, on: schedule, criteria: .firstBefore)
        
    case .firstAfter:
        let sorted = Array(schedule).sorted(by: <)
        if
            let valueAfter = sorted.first(where: {$0 > dayValue })
        {
            // we've got a possible value
            if
                rangeOfDays.contains(valueAfter)
            {
                // in case it fits in the daysRange for this month we're
                // good to go:
                return valueAfter - dayValue
            } else if includeLastMonthDay && dayValue < rangeOfDays.last! {
                // in case we are allowed to include last month day,
                // and dayValue is not last day of this month
                // we're good to go too by using this month's last day:
                return rangeOfDays.last! - dayValue
            }
        }
        // We have to check on next months:
        return daysShiftToAdjacentMonth(from: date, on: schedule, criteria: .firstAfter)
    }
    
    return nil
}

func daysShiftToAdjacentMonth(from baseDate: Date, on schedule: Set<Int>, criteria: CalendarCalculationMatchingDateDirection) -> Int?
{
    guard
        !schedule.isEmpty,
        schedule.isSubset(of: GregorianCommonTimetable.Kind.dailyBased.rangeOfScheduleValues),
        criteria != .on,
        let rangeOfDaysForBaseMonth = Calendar.gregorianCalendar.range(of: .day, in: .month, for: baseDate)
        else { return nil }
    
    let baseDayValue = Calendar.gregorianCalendar.component(.day, from: baseDate)
    let increment = criteria == .firstBefore ? -1 : 1
    var shift: Int = criteria == .firstBefore ?  -baseDayValue : rangeOfDaysForBaseMonth.last! - baseDayValue
    let sorted = Array(schedule)
        .sorted(by: <)
    var monthsShift = increment
    while
        abs(monthsShift) <= 12
    {
        guard
        let shiftedDate = Calendar.gregorianCalendar.date(byAdding: .month, value: monthsShift, to: baseDate),
        let daysRange = Calendar.gregorianCalendar.range(of: .day, in: .month, for: shiftedDate)
        else { break }
        
        let found = criteria == .firstBefore ? sorted
            .last(where: { daysRange.contains($0) }) : sorted
                .first(where: { daysRange.contains($0) })
        if
            let found = found
        {
            let iterShift = criteria == .firstBefore ? -(daysRange.count - found) : found
            shift += iterShift
            break
        }
        
        shift += daysRange.count * increment
        monthsShift += increment
    }
    
    return shift
}

// MARK: - Helpers for asyncGenerator
func scheduleElements(for generator: @escaping Schedule.Generator, of kind: GregorianCommonTimetable.Kind, in dateInterval: DateInterval) throws -> [DateInterval]
{
    let chuncks = chop(dateInterval: dateInterval, for: generator, of: kind)
    var fcResult: Result<[DateInterval], Swift.Error>!
    var scResult: Result<[DateInterval], Swift.Error>!
    let queue = DispatchQueue(label: "com.vdl.GregorianCommonTimetable.scheduleElements", qos: .userInitiated)
    let operationGroup = DispatchGroup()
    
    switch (chuncks.firstChunk, chuncks.secondChunk) {
    case (nil, nil):
        return []
    case (nil, .some(let smallest)):
        return generateElementsSerially(in: smallest, using: generator)
    case (.some(let firstChunck), _):
        operationGroup.enter()
        queue.async {
            do {
                let elements = try scheduleElements(for: generator, of: kind, in: firstChunck)
                fcResult = .success(elements)
            } catch {
                fcResult = .failure(error)
            }
            operationGroup.leave()
        }
    }
    
    if
        let secondChunck = chuncks.secondChunk
    {
        operationGroup.enter()
        queue.async {
            do {
                let elements = try scheduleElements(for: generator, of: kind, in: secondChunck)
                scResult = .success(elements)
            } catch {
                scResult = .failure(error)
            }
            operationGroup.leave()
        }
    } else {
        scResult = .success([])
    }
    
    let opGroupResult = operationGroup.wait(timeout: .now() + .seconds(2))
    
    guard
        opGroupResult == .success,
        case .success(let firstChunkElements) = fcResult,
        case .success(let secondChunkElements) = scResult
        else
    {
        throw GregorianCommonTimetable.Error.timeout
    }
    
    return firstChunkElements + secondChunkElements
}

func effectiveDateInterval(from dateInterval: DateInterval, for generator: @escaping Schedule.Generator) -> DateInterval?
{
    var startCandidate: Date? = nil
    var endCandidate: Date? = nil
    if
        let onStartElement = generator(dateInterval.start, .on),
        onStartElement.start >= dateInterval.start
    {
        startCandidate = onStartElement.start
    } else if
        let firstElementAfterStart = generator(dateInterval.start, .firstAfter),
        firstElementAfterStart.end <= dateInterval.end
    {
        startCandidate = firstElementAfterStart.start
    }
    
    guard
        let start = startCandidate
        else { return nil }
    
    if
        let onEndElement = generator(dateInterval.end, .on),
        onEndElement.end <= dateInterval.end
    {
        endCandidate = onEndElement.end
    } else if
        let firstElementBeforeEnd = generator(dateInterval.end, .firstBefore),
        firstElementBeforeEnd.start >= dateInterval.start
    {
        endCandidate = firstElementBeforeEnd.end
    }
    
    guard
        let end = endCandidate,
        start <= end
        else { return nil }
    
    return DateInterval(start: start, end: end)
}

func chop(
    dateInterval: DateInterval,
    for generator: @escaping Schedule.Generator,
    of kind: GregorianCommonTimetable.Kind
)
    -> (firstChunk: DateInterval?, secondChunk: DateInterval?)
{
    guard
        let effectiveDateInterval = effectiveDateInterval(from: dateInterval, for: generator)
        else { return (nil, nil) }
    
    guard
        let distance = largestDistance(for: effectiveDateInterval, kindOfGenerator: kind)
        else { return (nil, effectiveDateInterval) }
    
    // Safe to force unwrap since both dates are smaller
    // than the end end date of the given date interval (no overflow)
    // and Calendar.Component used in these calculations will produce
    // dates:
    let endAtDistance = Calendar.gregorianCalendar.date(byAdding: distance.component, value: distance.amount, to: effectiveDateInterval.start)!
    let endOfFirstChunk = Calendar.gregorianCalendar.date(byAdding: kind.durationComponent, value: -1, to: endAtDistance)!
    
    let firstChunk = DateInterval(start: effectiveDateInterval.start, end: endOfFirstChunk)
    
    let secondChunk = DateInterval(start: endOfFirstChunk, end: effectiveDateInterval.end)
    
    return (firstChunk, secondChunk)
}

func largestDistance(
    for dateInterval: DateInterval,
    kindOfGenerator: GregorianCommonTimetable.Kind
)
    -> (component: Calendar.Component, amount: Int)?
{
    /* Get the distance in DateComponents from start date
     to end date, using the bigger ones than the one the instance
     is refererring to.
    */
    let distance = Calendar.gregorianCalendar.dateComponents(kindOfGenerator.componentsForDistanceCalculation, from: dateInterval.start, to: dateInterval.end)
    
    /* Check for a significant distance between the two dates,
     and eventually return the values
    */
    if let years = distance.year, years > 0 {
        return (component: .year, amount: years)
    } else if let months = distance.month, months > 0 {
        return (component: .month, amount: months)
    } else if let weeks = distance.weekOfYear, weeks > 0 {
        return (component: .weekOfYear, amount: weeks)
    } else if let days = distance.day, days > 0 {
        return (component: .day, amount: days)
    } else {
        return nil
    }
}

// Declared private since testing is done on AnySchedule.
private func generateElementsSerially(in dateInterval: DateInterval, using generator: @escaping Schedule.Generator) -> [DateInterval]
{
    let sequence = AnySchedule(body: generator)
        .generate(start: dateInterval.start, end: dateInterval.end)
    
    return Array(sequence)
}
