//
//  GregorianCommonTimetable
//  GregorianCommonTimetable+Schedule.swift
//
//  Created by Valeriano Della Longa on 13/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import Schedule
import VDLCalendarUtilities

extension GregorianCommonTimetable: Schedule
{
    public var isEmpty: Bool {
        
        return onScheduleValues.isEmpty
    }
    
    public func contains(_ date: Date) -> Bool {
        let dateComponentValue = Calendar.gregorianCalendar.component(kind.component, from: date)
        
        return onScheduleValues.contains(dateComponentValue)
    }
    
    public func schedule(matching date: Date, direction: CalendarCalculationMatchingDateDirection) -> Self.Element? {
        return _generator(date, direction)
    }
    
    public func schedule(in dateInterval: DateInterval, queue: DispatchQueue?, then completion: @escaping (Result<[Self.Element], Swift.Error>) -> Void) {
        _asyncGenerator(dateInterval, queue, completion)
    }
    
}
