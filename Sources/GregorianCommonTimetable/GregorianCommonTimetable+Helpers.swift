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
        let onEndElement = generator(dateInterval.end, .firstBefore),
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
        let effectiveDateInterval = effectiveDateInterval(from: dateInterval, for: generator) else
    {
          return (nil, nil)
    }
    
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
